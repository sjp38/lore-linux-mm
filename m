Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 48D608E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 09:40:09 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id 42so5888399qtr.7
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 06:40:09 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g51si5867342qtc.224.2018.12.21.06.40.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 06:40:08 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBLEdlOZ045017
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 09:40:07 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2pgyt9q0h9-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 09:40:07 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Fri, 21 Dec 2018 14:29:53 -0000
Date: Fri, 21 Dec 2018 16:29:45 +0200
In-Reply-To: <20181220083423.40233348@lwn.net>
References: <1544130781-13443-1-git-send-email-rppt@linux.ibm.com> <20181220075912.GA12338@rapoport-lnx> <20181220083423.40233348@lwn.net>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH 0/2] docs/mm-api: link kernel-doc comments from slab_common.c
From: Mike Rapoport <rppt@linux.ibm.com>
Message-Id: <1E20B2F5-93F6-4763-9068-75630DF2541C@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On December 20, 2018 5:34:23 PM GMT+02:00, Jonathan Corbet <corbet@lwn=2En=
et> wrote:
>On Thu, 20 Dec 2018 09:59:13 +0200
>Mike Rapoport <rppt@linux=2Eibm=2Ecom> wrote:
>
>> ping?
>
>Sorry, been traveling,

No problem, I just wanted to make sure it didn't fall between the cracks=
=2E

> and I still don't really know what to do with
>patches that are more mm/ than Documentation/=2E=20

Well, these seem to be quite documentation, although they touch mm files ;=
-)

> I've just applied these, though=2E

Thanks!

>Thanks,
>
>jon

--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E
