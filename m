Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 157D2C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 07:54:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C8DE2184A
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 07:54:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="EhzMZZr+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C8DE2184A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F58D8E0003; Thu, 28 Feb 2019 02:54:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07C478E0001; Thu, 28 Feb 2019 02:54:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EADB28E0003; Thu, 28 Feb 2019 02:54:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE22A8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 02:54:05 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id l198so8680175oib.1
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 23:54:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Oge1v0CI7B6i3pkVqnC/QfefhOu5L2twbcqoTGVhkCQ=;
        b=lJownqZgkWQV6YYpCS1hng8CvH4pkTL58ACGSPcE3t5dSxIzdQzyEo9PwlLPCp3mcZ
         OgzxC0ci85EVwb2oywf2VkcU4aQ4hVU05TCzHLEBA/Ad5pVSuBGMbpbmiAphlE2I9Iv2
         vynAudR9Qp/vHUvbagdwrJmZ7t8EJvvfL2XDQSVUhh5CUIj8tj0k0FyLwHQo86pf2e80
         cm0JNH1oa/HFHlu91qA1R07znWj9MaEd6uFQISxvhzGB+NyxFuEOGc5d3v2VYhxavTEq
         c+Np9RxXhIKkcX0NZWzfVF2od1JsnLOQDO51t1HSZUuUwKIvIpCGC5FSk3mHvwwBtg08
         7JQQ==
X-Gm-Message-State: APjAAAWu44GfkW9Jzf0qq9zWoor6vXROo8Bu/jOc3QQqZKZ2cJ8HKhmz
	vKh/vYkIsQHLnIpc1dEqrt6Y19JXTzqv6ck8yXRwxUtlECbexC016LFzDs37RBMq4eFZFv4+S93
	BOB9sjkMdHY2gSsKRwLnoQHWw7WU0l2cadj+943TYY1bFMtcRuvXmDh6/2i5ks7JHfB80KNryKG
	6IK6a4UvjkeNKMXDXnNVGBR8/5AP9wKPUUR53q2deDW2u5C3SbymE5cp0rMVkxQ+YxM8FF28mZx
	Mi81sPHhphM7LzmNpoaOqKnUdpKsC0avCoR5qOd+LKa74YtUpbIQAwVhiFB/6J/H3eEWp66DqD6
	Ivk0HbUsnFheCo5r36ylpnaIvTS/gf5RBDvxjeVWzIKiv5FtU3O0+IWmhsZYzWuekQ3fD6Kk5bv
	l
X-Received: by 2002:aca:bd85:: with SMTP id n127mr313255oif.53.1551340445400;
        Wed, 27 Feb 2019 23:54:05 -0800 (PST)
X-Received: by 2002:aca:bd85:: with SMTP id n127mr313226oif.53.1551340444387;
        Wed, 27 Feb 2019 23:54:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551340444; cv=none;
        d=google.com; s=arc-20160816;
        b=cMgy7PVSE6a0Za3W3czeVrGs6kh90uT5ODkQnXI/j90Hkc/lYx9hurV2hbkmqCP3o5
         66dJCAVYfDrYOWjw7JG3RkzZYE8ym7DP0D4raX+NFAJyS/1k12e2exW+NEiittYXbjxa
         Soj+SP+UnSlynNGlidbYImQDz9Cuylo+5CQTZsZXpvY0p6cTknlE3i9nUuOn32bszOTo
         v81tYqFt8vMOFp2xA2ulYKoMwFLqMEbH8+JuT2rHVLRTagYgU5iDYriLV4mnwbmtLmH6
         p949ZXlv9lYiskzPS0dGtiGLVuagt/4uaXabxcsuiUoiKgbVXobn5P4P6gZSItGR8PUI
         Ud0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Oge1v0CI7B6i3pkVqnC/QfefhOu5L2twbcqoTGVhkCQ=;
        b=Jd9bV0Gu7RQgfs5qReYj/WdV3p+61/0OQ8eo30wSGQymiNfSMJVV789HU2JEN5taBm
         61XIZBNF+c7ZqyNuLaOBLsapLzbwB8lf5LXRyNMCwQGp7NKXxig9HUf2vpZ9Pxzyy6RI
         uUlKPsnk5XKARuuGpXSqekVl7uiDOPt0nt9LKZDZbedXqR8DdtuK0uUL3yIu8X7TEETP
         X7I0TplKikMnBEkZbQXuYBM1cA1bWc0Fh4uaynP19PTrumCFlfQe2cZtCWaj0dEgWBLA
         z7SbHHVuEUpidfKS/ozv/o4WfpJtcfQ7ESYrMphVpdovL5tNnIiSnnA8kbzPrsnTriXt
         fHVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=EhzMZZr+;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d130sor9342320oib.61.2019.02.27.23.54.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 23:54:04 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=EhzMZZr+;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Oge1v0CI7B6i3pkVqnC/QfefhOu5L2twbcqoTGVhkCQ=;
        b=EhzMZZr+sRfu5A8F4nCspWxurM7GYsUuit+M4eikNppiCN/FWZEg/OF2ZVRFUMf7Sm
         wzzbepq/XbXWubVw6VHXPdLE74Z4AEiqKZ5KsekOmYyYUUFPVlsqLgNJtZWjvI6/n7YU
         Xsh+BicS3fJnhOH8z8dWI20m0CauIc70eq0w0NUbdKeOIzovGSA546Ig//TY6MXLpOTX
         jr613YEjvSXUnJAG3sOsYnRvyj0B5T6Xj0V6A8SM12RY5MsMLvrUETkZmJ9bPdxaIsqS
         aVStzMCiTkjyVcpqYeAhNZEbo1VkW3Td7LQvioIiHqE8HHUN4U77ohdlQo8PWQttszpD
         1+LA==
X-Google-Smtp-Source: AHgI3IbkiPdsFeFzguag0b4I3zroh+QeHRG2uCIfc+UreYswnZM9YP/qszsvAyNGZLPR65RdvNitqZGb90bHbB/ahMU=
X-Received: by 2002:aca:4a10:: with SMTP id x16mr2100135oia.73.1551340443762;
 Wed, 27 Feb 2019 23:54:03 -0800 (PST)
MIME-Version: 1.0
References: <20190225185727.BCBD768C@viggo.jf.intel.com>
In-Reply-To: <20190225185727.BCBD768C@viggo.jf.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 27 Feb 2019 23:53:52 -0800
Message-ID: <CAPcyv4g8ACK6ZOmDWVVhCAwcoaxRZdXQDt_8D6Omckuop8DapQ@mail.gmail.com>
Subject: Re: [PATCH 0/5] [v5] Allow persistent memory to be used like normal RAM
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dave Jiang <dave.jiang@intel.com>, 
	Ross Zwisler <zwisler@kernel.org>, Vishal L Verma <vishal.l.verma@intel.com>, 
	Tom Lendacky <thomas.lendacky@amd.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux MM <linux-mm@kvack.org>, "Huang, Ying" <ying.huang@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Keith Busch <keith.busch@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, 
	Juergen Gross <jgross@suse.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[ add Stephen and Juergen ]

On Mon, Feb 25, 2019 at 11:02 AM Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> This is a relatively small delta from v4.  The review comments seem
> to be settling down, so it seems like we should start thinking about
> how this might get merged.  Are there any objections to taking it in
> via the nvdimm tree?
>
> Dan Williams, our intrepid nvdimm maintainer has said he would
> appreciate acks on these from relevant folks before merging them.
> Reviews/acks on any in the series would be welcome, but the last
> two especially are lacking any non-Intel acks:
>
>         mm/resource: let walk_system_ram_range() search child resources
>         dax: "Hotplug" persistent memory for use like normal RAM

I've gone ahead and added this to the libnvdimm-for-next branch for
wider exposure. Acks of course still welcome.

Stephen, this collides with commit 357b4da50a62 "x86: respect memory
size limiting via mem= parameter" in current -next. Here's my
resolution for reference, basically just add the max_mem_size
statement to Dave's rework. Holler if this causes any other problems.

diff --cc mm/memory_hotplug.c
index a9d5787044e1,b37f3a5c4833..c4f59ac21014
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@@ -102,28 -99,21 +102,24 @@@ u64 max_mem_size = U64_MAX
  /* add this memory to iomem resource */
  static struct resource *register_memory_resource(u64 start, u64 size)
  {
-       struct resource *res, *conflict;
+       struct resource *res;
+       unsigned long flags =  IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
+       char *resource_name = "System RAM";

 +      if (start + size > max_mem_size)
 +              return ERR_PTR(-E2BIG);
 +
-       res = kzalloc(sizeof(struct resource), GFP_KERNEL);
-       if (!res)
-               return ERR_PTR(-ENOMEM);
-
-       res->name = "System RAM";
-       res->start = start;
-       res->end = start + size - 1;
-       res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
-       conflict =  request_resource_conflict(&iomem_resource, res);
-       if (conflict) {
-               if (conflict->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY) {
-                       pr_debug("Device unaddressable memory block "
-                                "memory hotplug at %#010llx !\n",
-                                (unsigned long long)start);
-               }
-               pr_debug("System RAM resource %pR cannot be added\n", res);
-               kfree(res);
+       /*
+        * Request ownership of the new memory range.  This might be
+        * a child of an existing resource that was present but
+        * not marked as busy.
+        */
+       res = __request_region(&iomem_resource, start, size,
+                              resource_name, flags);
+
+       if (!res) {
+               pr_debug("Unable to reserve System RAM region:
%016llx->%016llx\n",
+                               start, start + size);
                return ERR_PTR(-EEXIST);
        }
        return res;

