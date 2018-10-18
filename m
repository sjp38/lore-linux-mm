Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D3EB96B0269
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 09:44:05 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x44-v6so18433640edd.17
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 06:44:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y10-v6si10770604edt.320.2018.10.18.06.44.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 06:44:04 -0700 (PDT)
Date: Thu, 18 Oct 2018 15:44:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/3] Randomize free memory
Message-ID: <20181018134402.GE18839@dhcp22.suse.cz>
References: <153861931865.2863953.11185006931458762795.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20181004074457.GD22173@dhcp22.suse.cz>
 <CAPcyv4ht=ueiZwPTWuY5Y4y1BUOi_z+pHMjfoiXG+Bjd-h55jA@mail.gmail.com>
 <20181009112216.GM8528@dhcp22.suse.cz>
 <CAPcyv4gAsyw7Tpp6QKQUA=P3k-Gw=KzutS-PzBiisnxQ1R24gw@mail.gmail.com>
 <20181010084731.GB5873@dhcp22.suse.cz>
 <CAPcyv4j1QZSk_soYY=xpMiv0exYzdGoa0uqWppSs_dJwF4TPnw@mail.gmail.com>
 <20181011115238.GU5873@dhcp22.suse.cz>
 <CAPcyv4i38LAh1-bDE5cAAV=pAWMQeOYSmWF7ucM+Qt2O+GYMWw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4i38LAh1-bDE5cAAV=pAWMQeOYSmWF7ucM+Qt2O+GYMWw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Kees Cook <keescook@chromium.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu 11-10-18 11:03:07, Dan Williams wrote:
> On Thu, Oct 11, 2018 at 4:56 AM Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > In any case, I believe the change itself is not controversial as long it
> > is opt-in (potentially autotuned based on specific HW)
> 
> Do you mean disable shuffling on systems that don't have a
> memory-side-cache unless / until we can devise a security benefit
> curve relative to shuffle-order? The former I can do, the latter, I'm
> at a loss.

Yes, enable when the HW requires that for whatever reason and make add a
global knob to enable it for those that might find it useful for
security reasons with a clear cost/benefit description. Not "this is tha
security thingy enable and feel safe(r)"
-- 
Michal Hocko
SUSE Labs
