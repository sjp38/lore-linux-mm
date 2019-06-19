Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E19FC31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 09:04:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C3BA20B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 09:04:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C3BA20B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3B5F6B0005; Wed, 19 Jun 2019 05:04:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEA688E0002; Wed, 19 Jun 2019 05:04:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB3AC8E0001; Wed, 19 Jun 2019 05:04:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A1C876B0005
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 05:04:07 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m23so7628692edr.7
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:04:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xNNV3S6Kss++8jlN3BK40Yi4FsbpFz6QrDvAgIE+I7U=;
        b=TmdLJJ8xM3nuMbqb1FKomuUVBvMee8g+nrB92ICndEBrX8yxyP1AuzugpUIF0VYH6K
         nKIUs+PpqhkLofB67Ou/c1h5rqQwqBFO6rV9FY5xbX7hmKBu+yH35pw3j2MMGn7Oehdr
         +4eSrz8+PYYZxZxH8TjylY9JtUD1zE0Na+b65w9fJQC67aC/DzSJU5gcJc0VaErnKO34
         2qxKGIXTt4JMunhfnEy+OoJ1Bn6iRCnY7J0uWsU0VMbN1eCS+YD9ONvauWO4AihWHX/F
         BywsBUNGbec+V53hQ8gWOBCc5f3nM9caF5BmnhyWoyL9L8MFTTf9UmLkjd4oI+Y0OO1V
         B3IA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAU6pGiw1jRV1d5Npod2W7Gtmn0ajh2PYODsbJbAtXWaQ+NP/Qe0
	7YiZHTlC3lKxbCrOMK5JcxoUnw68XMhHNY97+Jv8pzaIapt1KEHvpG9kumJWcxyq8GDvcw75TU8
	uHCLky6POXrb0fdkfVLDbhs4VfJ3Fnl2vH0Z3uKtS9os7k2HUHGQw6FUdASuOW7AwNQ==
X-Received: by 2002:a50:9590:: with SMTP id w16mr110234656eda.0.1560935047237;
        Wed, 19 Jun 2019 02:04:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxydncfrF2IubuwdlnWJUHbuS1qH3XXn0sGjsbTtCLD1i6sIGnoaCEFwwd/4Mo+B0K/Vijo
X-Received: by 2002:a50:9590:: with SMTP id w16mr110234585eda.0.1560935046619;
        Wed, 19 Jun 2019 02:04:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560935046; cv=none;
        d=google.com; s=arc-20160816;
        b=o3vnnc3aeOUSePYDhUoY8oUksitqzIGMihQd+3ZRRZEI5AmTMbnwcTSz1/TODkIFu5
         SRIPEygNZVbdv1POipAh0rK14eEwXPNut7q6CVnNnQZfi8ZVUtHoTbS/0KdGgtd+biAl
         dyg+2OeA2RQF6t+0IvIm8r50arq3MjV5uaxZ0tsabMGrbgHb5uUHCL7eJEwfgkhEJE5A
         aNn8n7nMrBff2qkNmD2Lls8FsAoSz9wh3mEDUGAf2wTklCi2Zb88KpdESzOK1TgMEICI
         4SdHI1uWJ/imyGVCTHB8OoDsygi5brBtOWbtu4k+xmFF0VCR4hvY2PE/aw7ebGB/6xxp
         rcog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xNNV3S6Kss++8jlN3BK40Yi4FsbpFz6QrDvAgIE+I7U=;
        b=WfBleBvwJHq8S/Ka6gD3KicUFbKvv5gcInS9eamGPivN8DJsEfe3NYp3ZjdAQ/XNKg
         p/C9Zs5Cf2EZWtfC1yQwHZvEU7wu7zsamAkT2aKEWyeffyyafqyZToyzO5sLHkeD+bOr
         IqxiL8Fi4caVpZ26/VHDr6/I7Mq5kv+TQHzWh/2IVRIRghX/rJkrjx6uI7f9soc8DE+I
         VEwvcf/R7Qb9s1eEN/rmHMhDJnWXMUEs0o81+tfSu3QAdoHW8bm3GI3w2WixhWACtlpL
         EXPr3O7DlAuUwlpLrU4nDHp9TgxXqkWuX41gP+Ksy4CJQ1Rga0GTZCn2bHEBQDheUWyN
         kI0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q25si339438ejs.164.2019.06.19.02.04.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 02:04:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2381DAF57;
	Wed, 19 Jun 2019 09:04:06 +0000 (UTC)
Date: Wed, 19 Jun 2019 11:04:05 +0200
From: Michal Hocko <mhocko@suse.com>
To: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.de>,
	Wei Yang <richardw.yang@linux.intel.com>, linux-mm@kvack.org,
	akpm@linux-foundation.org, anshuman.khandual@arm.com
Subject: Re: [PATCH v2] mm/sparse: set section nid for hot-add memory
Message-ID: <20190619090405.GJ2968@dhcp22.suse.cz>
References: <20190618005537.18878-1-richardw.yang@linux.intel.com>
 <20190619062330.GB5717@dhcp22.suse.cz>
 <20190619075347.GA22552@linux>
 <a52a196a-9900-0710-a508-966e725eae03@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a52a196a-9900-0710-a508-966e725eae03@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 19-06-19 10:51:47, David Hildenbrand wrote:
> On 19.06.19 09:53, Oscar Salvador wrote:
> > On Wed, Jun 19, 2019 at 08:23:30AM +0200, Michal Hocko wrote:
> >> On Tue 18-06-19 08:55:37, Wei Yang wrote:
> >>> In case of NODE_NOT_IN_PAGE_FLAGS is set, we store section's node id in
> >>> section_to_node_table[]. While for hot-add memory, this is missed.
> >>> Without this information, page_to_nid() may not give the right node id.
> >>
> >> Which would mean that NODE_NOT_IN_PAGE_FLAGS doesn't really work with
> >> the hotpluged memory, right? Any idea why nobody has noticed this
> >> so far? Is it because NODE_NOT_IN_PAGE_FLAGS is rare and essentially
> >> unused with the hotplug? page_to_nid providing an incorrect result
> >> sounds quite serious to me.
> > 
> > The thing is that for NODE_NOT_IN_PAGE_FLAGS to be enabled we need to run out of
> > space in page->flags to store zone, nid and section. 
> > Currently, even with the largest values (with pagetable level 5), that is not
> > possible on x86_64.
> > It is possible though, that somewhere in the future, when the values get larger
> > (e.g: we add more zones, NODE_SHIFT grows, or we need more space to store
> > the section) we finally run out of room for the flags though.
> > 
> > I am not sure about the other arches though, we probably should audit them
> > and see which ones can fall in there.
> > 
> 
> I'd love to see NODE_NOT_IN_PAGE_FLAGS go.

NODE_NOT_IN_PAGE_FLAGS is an implementation detail on where the
information is stored. I cannot say how much it is really needed now but
I can see there will be a demand for it in a longer term because
page->flags space is scarce and very interesting storage. So I do not
see it go away I am afraid.
-- 
Michal Hocko
SUSE Labs

