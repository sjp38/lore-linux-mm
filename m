Return-Path: <SRS0=s2+Z=O6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BA8FC43387
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 06:18:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 403B5217D9
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 06:18:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="COdD2YH8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 403B5217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDAB98E000B; Fri, 21 Dec 2018 01:18:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B88B18E0001; Fri, 21 Dec 2018 01:18:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A50938E000B; Fri, 21 Dec 2018 01:18:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4B1678E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 01:18:08 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e12so4910086edd.16
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 22:18:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Z2FHmaBlflrf9QUQop5IgR5jIVNSrnKow3guJqFNBp8=;
        b=CeTCe+D+IFlNxa1u55BR3+nc4p6IkhOflgOyj8qdG+TcO1vlBPRnLeNKGZFQOsBN66
         HGIiN98Pe7+qlTjchcV8/4+H4+iSh0ap/2K/VtTz63GMskFv9iH5BaVWmu/6GLRWgeBF
         lOnNU+nTaeSMrS1adFoPxAKLxcPYUHGi9jqFjppTOMWb1yK5wL3UvR9q1aCxeYo81+Uf
         N1V6EXWEsSiegq9EScCz6uRdtfrj6XiBycSXoquGxTMj6ZJkCzcluKCMkhTX7l0BIncl
         HygTzRXXEbJNF6VRgDEK2AZw0P6ZoWbGI4DfOgC8N1Vez0WVfSUeOwlKyQGST5KtIljY
         XCaA==
X-Gm-Message-State: AA+aEWZoHpcyQT3WA8nmctV6RWxQwhp1X2oLQHzw9M9L2TczDvFokB63
	bwlwmwJN0PFwzZjnEDTCSsDj14u/SuVtgChEaem9S0SI9gMrhO2tOcurdY2id0iXaRs3ftkL5jf
	FOK9//cgBSGMQ+qBfF/V8N1HFUfccqG/hOmjgv+EFkODgkh8o7F/K8VbK3+O6K+8V+2HSpyyM8I
	uBI+EupTvCrdPNBDfDGiQLA08JlSY2cGoe3KGc+ghuHbgyj1afBbTryRHvXfOCTzrpguCLtH5JJ
	82flhFJy7895EPBCHIPe6tddS/Y7jkSNcRjueY+2cWSAPnkXOlRZ8sZ44ioYvtetP7nPbCFYFcD
	4kloSJUrX+fvfLry1uXLC6KAUoPmOAkOCOCu7wn9AUiyBmUlJ1XKXuFQgWOT3UrXwDo8TDmjLu3
	a
X-Received: by 2002:a50:b5a5:: with SMTP id a34mr1342976ede.52.1545373087659;
        Thu, 20 Dec 2018 22:18:07 -0800 (PST)
X-Received: by 2002:a50:b5a5:: with SMTP id a34mr1342942ede.52.1545373086772;
        Thu, 20 Dec 2018 22:18:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545373086; cv=none;
        d=google.com; s=arc-20160816;
        b=vETvh6uqBt0EBkkmLOtFg3pVzdtgAOShjQ+qPwS2rtmoU7zhVQSimWCIoKo4AedExF
         gi9BuQKQAiHz6reAuwcP148FyOlJbE/ZHHU/9KiZW2FVaNwjKzW1vD2oC50eWDSAGjhz
         wBXnoAIAkxexsO+Bs5MlSSQAouhYfd7Ysur4lrcxAHPo5nLaGN2TgpFvoZlmMt/nRB8m
         SWwsWsdYHr/BSRgHOxDRv0Vj3dcf7D1o4igFzYUQ3QhEw79rOc83YzfnqJBXwjqkJ5te
         LQgxI9iU8dFXPpAlxdw/FgWU9xv1d/iE4H+IL/I8ujKtllec0zlGXJNAekBhEttuGskV
         sszQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Z2FHmaBlflrf9QUQop5IgR5jIVNSrnKow3guJqFNBp8=;
        b=tjmuAPnn7gTK/zKGQP8tUAUSolojgYpjpLTKgOOccE5xug69sp4VRVEezyYHmBESiA
         AMjh5CdaTY+M33F7hlZZS/jA9EL/hscLoG+R3x8WcPsdGFMSIci7u0dcmorWqNrXqh5W
         MMXLfSXjBSDGBRHHskTZyUPY9o39WXSAsfhK7m3pBTQh4FloALjiBaVi1w+SxxJYHW7K
         7Jf+YCrumdPyAq1gWDIewVN9miif/cEGV0UHd4nMVMdYQTkdUAEf1/B0E+D+LZQyAM4R
         VtAkTyodBTwqLHKS0TvpatgZWu0VkvTFwSUs7M6PDXO/uI4iVNEyfcMK1SviX9biDfXz
         eSlA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=COdD2YH8;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p50sor10173595eda.9.2018.12.20.22.18.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 22:18:06 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=COdD2YH8;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Z2FHmaBlflrf9QUQop5IgR5jIVNSrnKow3guJqFNBp8=;
        b=COdD2YH8/h3nimEm7utrbsKg4Ml7JYcY9DfP8E4scwbaGpuJsKCz3axXxnQG7d69l1
         iL3X8SQvyHRMbjCOZCMIocN9XR15PQllEuE4eo8XEU65Zx9bLCMJKjzSxLewFESRJFx4
         T77p1L0xMiGDxr4ZnpW7k7s0TP2FX5yXCwa0jiz5n5LHM5gJQkz1NqibcdKz0oqX8YwO
         ofRZu1KW+GwS7VkjKjsFHKByVkwclMRes1Q9IlluMx95VQuNcR0LkO9Qd7RYZ2Wt4yiZ
         B1gso9GMg0VbAatszoGRHbQz6WeXiLzFYztoLdNARRl8GpqZTbNeUeH7brzySblK7yna
         50nA==
X-Google-Smtp-Source: AFSGD/W295SA9uQLpCCc6OGp9eUjomqYd0htfZ7bydooizYHZi08nl66rQowi+RjD57V5T1tJ+ZpnXngOinhdNwztpM=
X-Received: by 2002:a50:9feb:: with SMTP id c98mr1312405edf.253.1545373086325;
 Thu, 20 Dec 2018 22:18:06 -0800 (PST)
MIME-Version: 1.0
References: <1545299439-31370-1-git-send-email-kernelfans@gmail.com>
 <1545299439-31370-3-git-send-email-kernelfans@gmail.com> <20181220113547.GC9104@dhcp22.suse.cz>
 <CAFgQCTvxNGTKD+DP_LxF86WoVnCHnPkWoSqdGeXQxXNVYD_orw@mail.gmail.com> <20181220124419.GD9104@dhcp22.suse.cz>
In-Reply-To: <20181220124419.GD9104@dhcp22.suse.cz>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Fri, 21 Dec 2018 14:17:54 +0800
Message-ID:
 <CAFgQCTsTTQLyEr6NG4QvpYuuovathge6t+1ej_1edkGCai-jXw@mail.gmail.com>
Subject: Re: [PATCHv2 2/3] mm/numa: build zonelist when alloc for device on
 offline node
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, 
	linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, 
	Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>, 
	David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
	Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	Michael Ellerman <mpe@ellerman.id.au>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181221061754.A9brWZ40gnryL4e4lZCl5uMMVW28JQoePSMonCOOHfw@z>

On Thu, Dec 20, 2018 at 8:44 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 20-12-18 20:26:28, Pingfan Liu wrote:
> > On Thu, Dec 20, 2018 at 7:35 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Thu 20-12-18 17:50:38, Pingfan Liu wrote:
> > > [...]
> > > > @@ -453,7 +456,12 @@ static inline int gfp_zonelist(gfp_t flags)
> > > >   */
> > > >  static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
> > > >  {
> > > > -     return NODE_DATA(nid)->node_zonelists + gfp_zonelist(flags);
> > > > +     if (unlikely(!possible_zonelists[nid])) {
> > > > +             WARN_ONCE(1, "alloc from offline node: %d\n", nid);
> > > > +             if (unlikely(build_fallback_zonelists(nid)))
> > > > +                     nid = first_online_node;
> > > > +     }
> > > > +     return possible_zonelists[nid] + gfp_zonelist(flags);
> > > >  }
> > >
> > > No, please don't do this. We do not want to make things work magically
> >
> > For magically, if you mean directly replies on zonelist instead of on
> > pgdat struct, then it is easy to change
>
> No, I mean that we _know_ which nodes are possible. Platform is supposed
> to tell us. We should just do the intialization properly. What we do now
> instead is a pile of hacks that fit magically together. And that should
> be changed.
>
Not agree. Here is the typical lazy to do, and at this point there is
also possible node info for us to check and build pgdat instance.

> > > and we definitely do not want to put something like that into the hot
> >
> > But  the cose of "unlikely" can be ignored, why can it not be placed
> > in the path?
>
> unlikely will simply put the code outside of the hot path. The condition
> is still there. There are people desperately fighting to get every
> single cycle out of the page allocator. Now you want them to pay a
> branch which is relevant only for few obscure HW setups.
>
Data is more convincing.
I test with the following program  built with -O2 on x86. No
observable performance difference between adding an extra unlikely
condition. And it is apparent that the frequency of checking on
unlikely is much higher than my patch.
#include <stdio.h>
#define unlikely_notrace(x)     __builtin_expect(!!(x), 0)
#define unlikely(x) unlikely_notrace(x)
#define TEST_UNLIKELY 1
int main(int argc, char *argv[])
{
        unsigned long i,j;
        unsigned long end = (unsigned long)1 << 36;
        unsigned long x = 9;
        for (i = 1; i < end; i++) {
#ifdef TEST_UNLIKELY
                if (unlikely(i == end - 1))
                        x *= 8;
#endif
                x *= i;
                x = x%100000 + 1;
        }
        return 0;
}

> > > path. We definitely need zonelists to be build transparently for all
> > > possible nodes during the init time.
> >
> > That is the point, whether the all nodes should be instanced at boot
> > time, or not be instanced until there is requirement.
>
> And that should be done at init time. We have all the information
> necessary at that time.
> --

Will see other guys' comment.

Thanks and regards,
Pingfan

