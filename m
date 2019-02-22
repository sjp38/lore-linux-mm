Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6E5CC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 14:31:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E0302075A
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 14:31:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E0302075A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D57BF8E010E; Fri, 22 Feb 2019 09:31:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D07F68E0109; Fri, 22 Feb 2019 09:31:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF5478E010E; Fri, 22 Feb 2019 09:31:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8EEE98E0109
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 09:31:57 -0500 (EST)
Received: by mail-vk1-f200.google.com with SMTP id e13so1138395vka.5
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 06:31:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=y4/edclAe1c+FKsvasVRxzFW1yOs+j0uy/mbO70zgdc=;
        b=pvPJQsYXqhN8m5ZNObZqGYta0F8veOyzDCLBjzMwJW1+yeEH0WAH1P8X5iXAar4+51
         uaSNMdnf7nuiuqycm/STiEkmHWK/mlO8EtAqoiyh477DbS1MBBscC2xxQlLx5nC67XVq
         WGqX534UsMdTqcVDyGIvpbgBf5NctNYcbFkUsu2I1kqVxbXKa03/SAT5oNUWsnvY4uWa
         bynUvVCGUe/F+8+kZblkIEs+CEcYAX2BJMqbIxN4Isoe3i/R/R9gfS+cYOJWfpchbMI4
         rcP2QHcztwDkIf2bi67AayaihbtxGNv9TDnuts63YiiLTQn11bPve7DP10QAydF9tXiB
         MU3w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAuZ1WOwFf04SQ/VdsxxkVjZeSCuCAkWSmIZDyiuYAAfoMP6HUaE0
	ME456Nsh3AlxafqbZBel/kUMVsOeUg/RywrUVmZPN5rLDSVXD+FH1AFoBIVmYCotfujD5ZB3kWJ
	uB5bYm9TObTXwR9qJMjNCk0yhj8/zdQNSzbTDVA8uBCaqADyAiLzERAZ7Yv0mLuKnGQ==
X-Received: by 2002:a1f:a5d3:: with SMTP id o202mr2419946vke.40.1550845917214;
        Fri, 22 Feb 2019 06:31:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbNiHPLd1hZR8SVvbPtjh2wJhv0L3MmgD1OcjWvxYP8rvv1FO84ShUvfECUyuIZVT6zkSVf
X-Received: by 2002:a1f:a5d3:: with SMTP id o202mr2419877vke.40.1550845915782;
        Fri, 22 Feb 2019 06:31:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550845915; cv=none;
        d=google.com; s=arc-20160816;
        b=ITw80VpC//1E0FT/QY0IXkB+p7WdHfyrGSA1/WrIMoyZRzGd43mCZXOYreraQEYa2r
         EgTTFL12jDqIEXZA8KkVLl1c3HlA4HybVDjLjZLkso37/vQ1q40LB8vNfQyjI68pRxrs
         tb78dxj9f+ImguKZ7ug4JIYajEZEzSJe5VEuqgEzeOjFxRm2Hs9R8raXavokDXukCeSp
         S6rf7B5HLDwTs6yL84s2LotIhroBHyQ4QQ3/izh5TPH2x2RLZozJtNAFcxyb4+QP/gcl
         Hg9/JBGLuueqnno+OiGqOwmknwhY5ibWacdjwdw5sGgpG7Dw17CzDoPrrOAJ87R8Ox45
         C7ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=y4/edclAe1c+FKsvasVRxzFW1yOs+j0uy/mbO70zgdc=;
        b=t5bPDbPXkpssWKsFfUN9AQ958BdyhZ48gT/q30K3bLTA3VdYylG5+N/Z99slo06wsY
         FGATpe1M3pxYCLww63w+v1aVp88xhprpgaeDD+j7SoJWudHTMRHcRp7kZHsSN3+HR8BO
         MHQkm267kI8wbtctt9XhrqNu+N1nMxFYwZgJLGhQLALRnp3f9Z8qgy2OkJ/qpziECdpv
         BQ5jSO10XkBXWiLa0JTYH4WDyLX5KWhQnTpeMfdHyL3AdlqsHMn3aazgNhAZJhRjK9R5
         zNWIJ5v/pvN/QAH472fZmMBZpZpgbWrsa2TxvUXqK54uirlzfDmz7Ut9R5oquPP12JbC
         Z7Dw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id h64si292531vsd.353.2019.02.22.06.31.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 06:31:55 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS401-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 19C3AFD67C370D31E725;
	Fri, 22 Feb 2019 22:31:50 +0800 (CST)
Received: from localhost (10.47.85.38) by DGGEMS401-HUB.china.huawei.com
 (10.3.19.201) with Microsoft SMTP Server id 14.3.408.0; Fri, 22 Feb 2019
 22:31:44 +0800
Date: Fri, 22 Feb 2019 14:31:31 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Jerome Glisse <jglisse@redhat.com>
CC: <lsf-pc@lists.linux-foundation.org>, <linux-mm@kvack.org>, Dan Williams
	<dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, "Felix
 Kuehling" <Felix.Kuehling@amd.com>, John Hubbard <jhubbard@nvidia.com>,
	"Keith Busch" <keith.busch@intel.com>, Mel Gorman
	<mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Paul Blinzer
	<Paul.Blinzer@amd.com>, <linux-kernel@vger.kernel.org>
Subject: Re: [LSF/MM TOPIC] NUMA, memory hierarchy and device memory
Message-ID: <20190222143131.00007afe@huawei.com>
In-Reply-To: <20190118174512.GA3060@redhat.com>
References: <20190118174512.GA3060@redhat.com>
Organization: Huawei
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
X-Originating-IP: [10.47.85.38]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 Jan 2019 12:45:13 -0500
Jerome Glisse <jglisse@redhat.com> wrote:


Hi Jerome,

I held off on replying to this given we've had quite a few productive
discussions about it in the past and I wanted to see what others came back
with.  They've had plenty of time, so I'll put my inputs on the table ;)

> Hi, i would like to discuss about NUMA API and its short comings when
> it comes to memory hierarchy (from fast HBM, to slower persistent
> memory through regular memory) and also device memory (which can have
> its own hierarchy).
>=20
> I have proposed a patch to add a new memory topology model to the
> kernel for application to be able to get that informations, it
> also included a set of new API to bind/migrate process range [1].
> Note that this model also support device memory.

As an aside,
I was a bit disappointed at the fact that current HMAT description
being exported to userspace is currently limited to 'best' node
only.  This is obviously much simpler than what you propose, but
even in that case we need examples to show how userspace can
make use of the much richer information that is there and not
currently made available.  Right now the only way (I think) userspace
can make use of that more detailed information is to parse HMAT
directly.  We can probably work with that to 'prove' the requirement
but it's certainly ugly!

>=20
> So far device memory support is achieve through device specific ioctl
> and this forbid some scenario like device memory interleaving accross
> multiple devices for a range. It also make the whole userspace more
> complex as program have to mix and match multiple device specific API
> on top of NUMA API.
>=20
> While memory hierarchy can be more or less expose through the existing
> NUMA API by creating node for non-regular memory [2], i do not see this
> as a satisfying solution. Moreover such scheme does not work for device
> memory that might not even be accessible by CPUs.

I agree with this point even though I mostly care about 'normal' memory
(be it in random places in the system). Hence my life is a little easier
as correctness is easy even if performance is not.

>=20
> Hence i would like to discuss few points:
>     - What proof people wants to see this as problem we need to solve ?

Agreed, this question in crucial to any discussion of more complex handling.
I'm mostly interested in the 'easier' case of coherent 'normal' memory over
CCIX.   However, a lot of the questions around migration and topology
are the same just perhaps simpler to implement.

In CCIX we also have the major advantage that 'most' of our topology is
discoverable by sufficiently clever userspace (excluding the host unfortuna=
tely).
It does give us a 'playground' to look at some of these issues and we'll
definitely be exploring them as more complex systems become readily availab=
le.

As has been discussed before, we need to know who the user groups for this
information actually are and the following questions:

1) Are they dealing with few enough hardware topologies that they can 'know'
   what they have to tune against?  Still might need more advanced interfac=
es
   to do it, but they are likely to be device specific.  This is perhaps
   the HPC world at the moment.   This is a good group to work with if they
   are willing to prove the benefit, but do they justify a proper kernel
   description. Probably not if it's just them.

2) If not the above, but rather standard workstations or highly customizable
   systems, will the software be able to make the right decisions?
   To a degree, this last bit could just be a case of a library that can
   abstract away the complexity the the questions people actually want to
   answer (under a given list of constraints, including load information):
     a) Where should I run this code?
     b) Where should I store this data?

My instinct is expose everything to userspace, but I appreciate that brings=
 a
very steep learning curve and chances are is near impossible to do in a sen=
sible
fashion.  What I do care a lot about is exposing enough topology information
that other data can be used intelligently.  If I have a PMU on a particular
interconnect I want to be able to tell which memory in my system is
on which side of that interconnect.  Right now I need the system manuals to=
 find
that out.  Arguably those PMUs are sufficiently non standard that no
generic software could use them anyway, but that is likely to change in the
next year or two as standardization catches up with reality.
=20
>     - How to build concensus to move forward on this ?

A hard question indeed.  My worry is we are still too early in the availabi=
lity
of these highly heterogeneous systems.  Good to start making progress now,
but it may be a while before we have clarity.  I know you have systems
that are, perhaps, rather less bleeding edge than mine, so your urgency
to solve this may be higher!

Having said that, there is clear demand from the hardware specifications
bodies, for some idea of where operating systems are going, so that they
can make decisions on exactly what level of self description their
hardware should provide, to feed up the chain.  I've been sat in meetings
where hardware specs have not done this because we have no clarify on what
the operating systems want. Much as with the firmware people, no one wants
to specify information must be provided that nothing uses, or that might
potentially be the 'wrong' information.

Anyhow, hard and interesting topic. I'm sure this discussion and its
follow ups keep us busy for a few years yet.  Good to make a start and
hopefully clarify the 'requirements' for any proposal as you've suggested.

Jonathan

>     - What kind of syscall API people would like to see ?
>=20
> People to discuss this topic:
>     Dan Williams <dan.j.williams@intel.com>
>     Dave Hansen <dave.hansen@intel.com>
>     Felix Kuehling <Felix.Kuehling@amd.com>
>     John Hubbard <jhubbard@nvidia.com>
>     Jonathan Cameron <jonathan.cameron@huawei.com>
>     Keith Busch <keith.busch@intel.com>
>     Mel Gorman <mgorman@techsingularity.net>
>     Michal Hocko <mhocko@kernel.org>
>     Paul Blinzer <Paul.Blinzer@amd.com>
>=20
> Probably others, sorry if i miss anyone from previous discussions.
>=20
> Cheers,
> J=E9r=F4me
>=20
> [1] https://lkml.org/lkml/2018/12/3/1072
> [2] https://lkml.org/lkml/2018/12/10/1112


