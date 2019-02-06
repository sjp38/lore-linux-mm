Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DA15C282CC
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 16:13:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1836E20821
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 16:13:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1836E20821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE1278E00C9; Wed,  6 Feb 2019 11:13:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D90DB8E00B1; Wed,  6 Feb 2019 11:13:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA64A8E00C9; Wed,  6 Feb 2019 11:13:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8846F8E00B1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 11:13:00 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 74so5532903pfk.12
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 08:13:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lWM47uwISVHEamCMEt3fdL/KOztFOsFIvYxVV2PdMt4=;
        b=jzRBHmSNFaH7+fQ9ffpDZBBVafAcamclq3bU9OMA175UVUsr2U4sLITzfJofWInS8U
         0BnQjgxdc5IKtegygJjdtj1PsEIH0U9PyiHETNEx8Ns2YbifXFsExR4xzhhjl4FPWGyG
         5KdT005pqxzvfD7vUmgvdoXVWEqnjj1v77iXNCNcG/rRaeW8ks6oQMWXoYvJuI5CAj0U
         mbf52MR+KmFnAHi4WCQHchgZlaHts4VbN5j210a5kfTMEYTeYTiIMsFWDys6THaFurfB
         2B8yOzdBj1hCznjGA741jdgJuuOg2S5iOOLj51C7VLCWHM87Rh72YLcfZkRSYYGKYVq7
         5gfA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubgcSXdeJa8r5uQSQd5Tes8FFckO8RfpW3VANob3F8CnkNHjc/p
	VC95mznk2xk3W3lXKwollKV2AA89Ry4p5PDUMAPKvJNrlUsqkz6MGgefjC3UHlEjbGsYEf3wmfx
	/exKshjtqs0KUOfOVfKcPanYCKSvFsGLdCfKVxd/NP70RJYLOQW6ToAFJQuBo232U8g==
X-Received: by 2002:a62:2cf:: with SMTP id 198mr11239012pfc.67.1549469580195;
        Wed, 06 Feb 2019 08:13:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYHpqIcm5kLxE/mljvMAdPc4kamsY5DShPP2YTn0Uy2loHZzY52ICBejSH0+P3XyZ6ViBWM
X-Received: by 2002:a62:2cf:: with SMTP id 198mr11238948pfc.67.1549469579394;
        Wed, 06 Feb 2019 08:12:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549469579; cv=none;
        d=google.com; s=arc-20160816;
        b=HLfUI/yV/VzyyQnUtTqSiW8WTDg7Y4T3psffC79LqA+WfvCotmJyHNjug7TdyQ8EBc
         WdNbMRr88Pjllbu9/9mbE3WbXvuoofdoD+wznMahOAHGkFP5kEtgIANxUwq+xTT6s/Lr
         udS/5JNzxegeObMJX0FZci13C2XLlWP35Rx9r+dol9mAChiE72CvIKQGjkVBR1s2/t9o
         KuFOTZ74E0Qqvfwtgh0wpVDnIghUg0Ki/OuwJfyhbeZaZ9xtz+XdnEKa8gDTnmEpX9Cl
         XW+Rvn7wN11SGHnnnz5U3sFwOx6A/9EMQ0U88XEsCWOUTgFAtzq07p5qMYu69C8vQrMI
         WjfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lWM47uwISVHEamCMEt3fdL/KOztFOsFIvYxVV2PdMt4=;
        b=GPQ5p08yA6tT5qhz8kAyAyrODPP5xdSyBxmwSZoFOpldtyB0KvvZBB5m0bgEs/0xXa
         p0DUgDfYr+cEc9T1XkUtGFPx2SLqBjkwYvXbBNJzcqH+svhLrXqcKsMx/Gld95vP+P23
         +GcPC/1HP90oi2TrApLeZNuixRQ50XJEF0/PYZefHLFiEwCnwAMXDhgKTS/UYaNqG3iy
         UG5YIGvNXgIKv/+WmWAF+9gGcf5rc1gC6KeWBkF/QcAmAplMdxTDKpskA6G0qD6Mpozu
         Jqay2sJhmhTGVZC9azbWblJhZEaWHYF9kmII0HFA3pKJJ/ubQt/XdX7PjFeFpdsuQdew
         3Gvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id o9si6432424pfe.63.2019.02.06.08.12.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 08:12:59 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Feb 2019 08:12:58 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,340,1544515200"; 
   d="scan'208";a="141188798"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by fmsmga002.fm.intel.com with ESMTP; 06 Feb 2019 08:12:58 -0800
Date: Wed, 6 Feb 2019 09:12:27 -0700
From: Keith Busch <keith.busch@intel.com>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	"Hansen, Dave" <dave.hansen@intel.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>
Subject: Re: [PATCHv5 04/10] node: Link memory nodes to their compute nodes
Message-ID: <20190206161227.GH28064@localhost.localdomain>
References: <20190124230724.10022-1-keith.busch@intel.com>
 <20190124230724.10022-5-keith.busch@intel.com>
 <20190206122635.00005d37@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190206122635.00005d37@huawei.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 04:26:35AM -0800, Jonathan Cameron wrote:
> On Thu, 24 Jan 2019 16:07:18 -0700
> Keith Busch <keith.busch@intel.com> wrote:
> > +What:		/sys/devices/system/node/nodeX/accessY/initiators/
> > +Date:		December 2018
> > +Contact:	Keith Busch <keith.busch@intel.com>
> > +Description:
> > +		The directory containing symlinks to memory initiator
> > +		nodes that have class "Y" access to this target node's
> > +		memory. CPUs and other memory initiators in nodes not in
> > +		the list accessing this node's memory may have different
> > +		performance.
> 
> Also seems to contain the characteristics of those accesses.

Right, but not in this patch. I will append the description for access
characterisitics in the patch that adds those attributes.
 
> > + * 	This function will export node relationships linking which memory
> > + * 	initiator nodes can access memory targets at a given ranked access
> > + * 	class.
> > + */
> > +int register_memory_node_under_compute_node(unsigned int mem_nid,
> > +					    unsigned int cpu_nid,
> > +					    unsigned access)
> > +{
> > +	struct node *init_node, *targ_node;
> > +	struct node_access_nodes *initiator, *target;
> > +	int ret;
> > +
> > +	if (!node_online(cpu_nid) || !node_online(mem_nid))
> > +		return -ENODEV;
> 
> What do we do under memory/node hotplug?  More than likely that will
> apply in such systems (it does in mine for starters).
> Clearly to do the full story we would need _HMT support etc but
> we can do the prebaked version by having hmat entries for nodes
> that aren't online yet (like we do for SRAT).
> 
> Perhaps one for a follow up patch set.  However, I'd like an
> pr_info to indicate that the node is listed but not online currently.

Yes, hot plug is planned to follow on to this series.

> > +
> > +	init_node = node_devices[cpu_nid];
> > +	targ_node = node_devices[mem_nid];
> > +	initiator = node_init_node_access(init_node, access);
> > +	target = node_init_node_access(targ_node, access);
> > +	if (!initiator || !target)
> > +		return -ENOMEM;
>
> If one of these fails and the other doesn't + the one that succeeded
> did an init, don't we end up leaking a device here?  I'd expect this
> function to not leave things hanging if it has an error. It should
> unwind anything it has done.  It has been added to the list so
> could be cleaned up later, but I'm not seeing that code. 
> 
> These only get cleaned up when the node is removed.

The intiator-target relationship is many-to-many, so we don't want to
free it just because we couldn't allocate its pairing node. The
exisiting one may still be paired to others we were able to allocate.

