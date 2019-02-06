Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 346F7C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 16:47:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDFA220818
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 16:47:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDFA220818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D0518E00D5; Wed,  6 Feb 2019 11:47:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 980218E00D1; Wed,  6 Feb 2019 11:47:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 897588E00D5; Wed,  6 Feb 2019 11:47:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1498E00D1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 11:47:46 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id x1so3161126vsc.0
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 08:47:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=YyNIoJmFS+MbFMyN/idn4BdmVkNBI2zIf6UVcYzoyaI=;
        b=RpN2ah69TSjaCNMeZCJKE1GLA40oM3PBfp2xzSkKVwOA3FVR24FFoWIATUjFNDf8DZ
         2ZcXZLDojduc+JjrmioAsx+431mUah1POjygbsTUCbP47bVa1wEidtiTkxZ1lSttlsGs
         SAhfWDfiDh7wv+qVWisCuZwaketOR+yMdP8iuzXJkX2IFDaQBAxxWd6a7vYiW899uZMI
         LQP983JavVweayrAOuZQynXHfRoReRaRTymT1X74TssF4nHf2QB1cHLwrBqRTJzi0zdA
         GaHm4ZCoKWGZTXVDAWmKQ8vUjA26VzhdwUKRuFfdSQoqEJSyOZnId34QujX3o4/NYacJ
         tJTg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAub2FazNq/YdkLvPFyA7WpXbDVilWj49FBk1nz2j54GXCzBAwsGA
	SdZUOmK0bUPmYKrmvvjaj0GCn340WwxMHDhGEmgu0vStWGZd3r9e0M+WoUEmGsad7TNUg2plKId
	OR5oNzCp42eolUtJFWPNjkz04z1yizTh7kShLXbl4DiPnsrmFovNDQt2Dd7CEks3W/A==
X-Received: by 2002:ab0:2082:: with SMTP id r2mr135757uak.119.1549471666003;
        Wed, 06 Feb 2019 08:47:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbLSNV+jFt5f2oEjV7sPwqLWFUpmlEuwyl2C90He20w9IjqQvfc8FhQk/fWqN/RKQaPFPWc
X-Received: by 2002:ab0:2082:: with SMTP id r2mr135729uak.119.1549471665165;
        Wed, 06 Feb 2019 08:47:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549471665; cv=none;
        d=google.com; s=arc-20160816;
        b=TGs5CUj2E4i7iaQL6kbIt4CVpuiotE4q45VBDzNDFZTh53Aw5IRCrHedbgHjzhF0ak
         uo5hpRblt7OJzd/MPyWSSP29ys7AOlCx6vVPeLhaHzZabdtScOLrOJY0XdJXNH01hC1E
         eQmJ0DEc5El6B0dRJAoYw1Ofrpt0rvMdNskORU4rGkmXhqoX9Ct/t2goyV53haBMMQXB
         VVLrXJi+ne+GFvGRKBEOfc42kQDdR7et9ZYOpQ4mU7Oxx0Te7b0BdGi464BMB00jjp01
         HcmQzOyo/zLXN2J6m448blROpfFDkVjqE7ESXwgjg9RQWf+yMFjpM9fuMnwOVwCkZczM
         9+yA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=YyNIoJmFS+MbFMyN/idn4BdmVkNBI2zIf6UVcYzoyaI=;
        b=dw2izrNv7rgvdTeZkYm/oO94zupqMZCrWKmOVuuWyN+0kAVOo2sG70BPPdSkN6TiYF
         Qne0vbKrBJAubMeZRUWDPstDGm5gj0oHJ1u/qlCbaeQ7DWtYc8KMr5D3zKpxcRsKg8XJ
         R2RPauW61Ttd9r8rtrbfuybBKrciBotXqaZrZ41u4q3Cc+6HRPafNx5x/isFHJcgxbvL
         xvgzQs+stD+WWUIsV4FGBpQFf0hYEChImyHvTFWgo+GbwhtZyijctHHWIySU1zdGzLKN
         qmM299JhiYOjG0OXYbPY983ANl6TiYEKR+CSmv94iAl3WcmYp91LDlPMjao1bLRraHCF
         hyug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id w3si3124862uan.18.2019.02.06.08.47.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 08:47:44 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS411-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id A543F91B5040A52C41F5;
	Thu,  7 Feb 2019 00:47:40 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS411-HUB.china.huawei.com
 (10.3.19.211) with Microsoft SMTP Server id 14.3.408.0; Thu, 7 Feb 2019
 00:47:34 +0800
Date: Wed, 6 Feb 2019 16:47:24 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, "Hansen,
 Dave" <dave.hansen@intel.com>, "Williams, Dan J" <dan.j.williams@intel.com>
Subject: Re: [PATCHv5 04/10] node: Link memory nodes to their compute nodes
Message-ID: <20190206164724.000019c5@huawei.com>
In-Reply-To: <20190206161227.GH28064@localhost.localdomain>
References: <20190124230724.10022-1-keith.busch@intel.com>
	<20190124230724.10022-5-keith.busch@intel.com>
	<20190206122635.00005d37@huawei.com>
	<20190206161227.GH28064@localhost.localdomain>
Organization: Huawei
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Feb 2019 09:12:27 -0700
Keith Busch <keith.busch@intel.com> wrote:

> On Wed, Feb 06, 2019 at 04:26:35AM -0800, Jonathan Cameron wrote:
> > On Thu, 24 Jan 2019 16:07:18 -0700
> > Keith Busch <keith.busch@intel.com> wrote:  
> > > +What:		/sys/devices/system/node/nodeX/accessY/initiators/
> > > +Date:		December 2018
> > > +Contact:	Keith Busch <keith.busch@intel.com>
> > > +Description:
> > > +		The directory containing symlinks to memory initiator
> > > +		nodes that have class "Y" access to this target node's
> > > +		memory. CPUs and other memory initiators in nodes not in
> > > +		the list accessing this node's memory may have different
> > > +		performance.  
> > 
> > Also seems to contain the characteristics of those accesses.  
> 
> Right, but not in this patch. I will append the description for access
> characterisitics in the patch that adds those attributes.
>  
> > > + * 	This function will export node relationships linking which memory
> > > + * 	initiator nodes can access memory targets at a given ranked access
> > > + * 	class.
> > > + */
> > > +int register_memory_node_under_compute_node(unsigned int mem_nid,
> > > +					    unsigned int cpu_nid,
> > > +					    unsigned access)
> > > +{
> > > +	struct node *init_node, *targ_node;
> > > +	struct node_access_nodes *initiator, *target;
> > > +	int ret;
> > > +
> > > +	if (!node_online(cpu_nid) || !node_online(mem_nid))
> > > +		return -ENODEV;  
> > 
> > What do we do under memory/node hotplug?  More than likely that will
> > apply in such systems (it does in mine for starters).
> > Clearly to do the full story we would need _HMT support etc but
> > we can do the prebaked version by having hmat entries for nodes
> > that aren't online yet (like we do for SRAT).
> > 
> > Perhaps one for a follow up patch set.  However, I'd like an
> > pr_info to indicate that the node is listed but not online currently.  
> 
> Yes, hot plug is planned to follow on to this series.
> 
> > > +
> > > +	init_node = node_devices[cpu_nid];
> > > +	targ_node = node_devices[mem_nid];
> > > +	initiator = node_init_node_access(init_node, access);
> > > +	target = node_init_node_access(targ_node, access);
> > > +	if (!initiator || !target)
> > > +		return -ENOMEM;  
> >
> > If one of these fails and the other doesn't + the one that succeeded
> > did an init, don't we end up leaking a device here?  I'd expect this
> > function to not leave things hanging if it has an error. It should
> > unwind anything it has done.  It has been added to the list so
> > could be cleaned up later, but I'm not seeing that code. 
> > 
> > These only get cleaned up when the node is removed.  
> 
> The intiator-target relationship is many-to-many, so we don't want to
> free it just because we couldn't allocate its pairing node. The
> exisiting one may still be paired to others we were able to allocate.

Reference count them?  We have lots of paths that can result in
creation any of which might need cleaning up. Sounds like a classic
case for reference counts.

Jonathan


