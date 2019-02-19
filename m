Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEE70C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:21:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49F812083B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:21:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="wIBf3yip"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49F812083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D99C88E0004; Tue, 19 Feb 2019 12:21:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D49F88E0002; Tue, 19 Feb 2019 12:21:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3A148E0004; Tue, 19 Feb 2019 12:21:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 996C28E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:21:17 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id a1so17766665otl.9
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 09:21:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ryAQx0eVnsFaBRoyj/Aqm9Xj5ZU4/2+jLsvZlamla6w=;
        b=EkCZNGVoNLafguHUxnY1+Xhj6JAgsXig5gcVs7iFj+tZAJjMBI5g1iAOuqCeCvBJix
         DavC29inOBX9rzWY+Vvu0WAzg0B0Pkan8FiSyyqSRIhSvptpdC/mGyNYXFsfvkht905n
         f8EGzhRNzyrxnJ+OhPSUxvgj0GeXu1rWz80myY5OsMXY19VWi2Cj6XKc3poVRlcAZZoe
         GxSZd0O8UE+scpEMcVn4L+IvBvLnXd8+f1CFLX5pZ2NWRQ3OdeHCmi2/vvm76f/9vSAL
         c3MEKdLIdKyPlH+AGHz+SOK6WKDra+QNbaWtFKJ1fcdB9N6BdXmElZL8YgTRGQRlEg6q
         IXzw==
X-Gm-Message-State: AHQUAuZfC6SxvaEZ/xUAP2ifpl/kynUEmL69JIwkjI15GnOdFF2z3laP
	nkJhnqvzCNYKIAC+CxmWiSw+MC8q2gMXaPmqhmWQTBLOWLUSDsyOkwGI7wzRBF49ZQITYc+bEZp
	WH9eVIVxC06AHDtKbQMvDhU7D+Sc2Ks8PBQP/eCCtUwQgC0q/D21jJih/avWzHaGDcnkvYBNL8e
	gALMpfLXJgE73RuoCaRF75/aG4+aWz2rlN2Nr9qcwGK5/ijaUAMIAzOUkn/z9KLNRH0yRcASKIo
	op3zeN69m8C/A6A1BTjQRFu84SRTXfS5yfC5D4+tq5zK2LmZiKgxMV7ved+wZ4OjiAfhEH7ZwVI
	Ihapw9W1NNGJluPnqJW0CjVgqvY1oBt6HdDDaXGubJno0nYYyzDPtHc5o8qCztyJaL1HBqH/KDo
	5
X-Received: by 2002:aca:cc06:: with SMTP id c6mr3043399oig.168.1550596877347;
        Tue, 19 Feb 2019 09:21:17 -0800 (PST)
X-Received: by 2002:aca:cc06:: with SMTP id c6mr3043346oig.168.1550596876407;
        Tue, 19 Feb 2019 09:21:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550596876; cv=none;
        d=google.com; s=arc-20160816;
        b=PtwzHh96BUmtP49sIAMhPuZ0Fhlx7hztAEzjyE9cXMOett8Bt7oNVm9p1R0m0fgyZH
         YxZbAjNgdB/bFkyaCGwgFMxyXtqcoy4Q0xG8ZJSWbGjenaJU/VqpsgXkcXKg4mDlZ+D5
         mUWTwLjUtI1pMlPiw87mVwTFMcNS8bC7kTXnhcz1XdskFiI3vGWGILkNcytdG/tYODB/
         c91ezmfVCbWLLVK5Ud1oS+EitI+5a6E785g2Pgmj5OcqnI32QBp9ilcZMNZ3axS+RUzD
         m9E71mpW4VaziDNGhI5c6dm48qdxGOSBcoKE25kxiaibwh2ZADRzFLDNeGQv4/r3jAHd
         Qg0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ryAQx0eVnsFaBRoyj/Aqm9Xj5ZU4/2+jLsvZlamla6w=;
        b=VqAA/cg7Ph62vtOtzydJvSx7XrW3pfOUsvXXrGO3a/35K/V5pg7PqxeQou9gPz0Pll
         maM6Iok66SNIN2swH1sW+kro2eFWp74rXDCkLW8XRKYr/0hmTaHw/W4L5+Soov0MxX+z
         6TY4RORVEI7h80n69cxrjJvqmZQF6eptMutms5KPJ/VXsaNGQukR3PHwDaXeT8XYKE1G
         BK/F13WioJz1flbtNK2kOHMSW9C0X1kT5ZfDpkkL+8AHLANYftOLlpKYhrQ4o9YwuSl2
         7GA1UTqhluMF8guZHu/KL9v5prFASmJf3XV8tD1szp9q8SH0ihXsYcqxBJr/b1sbFHVS
         obDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=wIBf3yip;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g1sor6997410oti.34.2019.02.19.09.21.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Feb 2019 09:21:16 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=wIBf3yip;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ryAQx0eVnsFaBRoyj/Aqm9Xj5ZU4/2+jLsvZlamla6w=;
        b=wIBf3yipRO+l0XcyAv6d3K1DP9jpRwd+IldHS4k7GZRYS8Pa1ClJMyIJWisvmH3EmX
         ryQVJuatBrDmoMgULUP9zWW+hGrvqa4zcN3x4s3oDrgLYZTRkbz2ayi1CkodNnRaUg0+
         XxFvHwB2T9skWsHhdqOiC5gwQAJlAZYvtXxJ1WR3iqDvakQiVe8MQprDxDhxA3bQS1vD
         QqgJHb3FG9O1jXi8UB9PoUsxer32oEFHJrbT0uw8c3kNspfMPCJurQPmFuw9UGbR6J7n
         qd2tpX83P0kd/ihHcXMP/F2SD95DDFjyK1nJ4OLyoAQGrR3i7g+hv+pSiitn+lB6WJ75
         DOpQ==
X-Google-Smtp-Source: AHgI3IabMTTtMCANoEAm9u/yt6MTkzJywrPCaORBEHuWmy67T3mEXwDsosPfa9WaWm+ZdSUoQw88DALgXj+tnqoHQBQ=
X-Received: by 2002:a9d:37b7:: with SMTP id x52mr19722344otb.214.1550596876126;
 Tue, 19 Feb 2019 09:21:16 -0800 (PST)
MIME-Version: 1.0
References: <154899811208.3165233.17623209031065121886.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154899812264.3165233.5219320056406926223.stgit@dwillia2-desk3.amr.corp.intel.com>
 <4672701b-6775-6efd-0797-b6242591419e@suse.cz>
In-Reply-To: <4672701b-6775-6efd-0797-b6242591419e@suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 19 Feb 2019 09:21:04 -0800
Message-ID: <CAPcyv4g5YwQFVjz+TLSwZZ7LE9h+JU==+KDrL37025dXMyXWoA@mail.gmail.com>
Subject: Re: [PATCH v10 2/3] mm: Move buddy list manipulations into helpers
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Keith Busch <keith.busch@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 7:24 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 2/1/19 6:15 AM, Dan Williams wrote:
> > In preparation for runtime randomization of the zone lists, take all
> > (well, most of) the list_*() functions in the buddy allocator and put
> > them in helper functions. Provide a common control point for injecting
> > additional behavior when freeing pages.
> >
> > Acked-by: Michal Hocko <mhocko@suse.com>
> > Cc: Dave Hansen <dave.hansen@linux.intel.com>
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> Here's another fixlet to fold into mm-move-buddy-list-manipulations-into-helpers.patch
> This time not critical.
>
> ----8<----
> From 05aaff61f62f86e646c4a2581fe2ff63ff66a199 Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Tue, 19 Feb 2019 16:20:33 +0100
> Subject: [PATCH] mm: Move buddy list manipulations into helpers-fix2
>
> del_page_from_free_area() migratetype parameter is unused, remove it.

Looks good,

Acked-by: Dan Williams <dan.j.williams@intel.com>

