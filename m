Message-ID: <4874E93F.7060602@linux-foundation.org>
Date: Wed, 09 Jul 2008 11:37:19 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [Bug]: Oops on ppc64 2.6.5-7.244-pseries64 in mm/objrmap.c
References: <2206.10.16.10.158.1215613660.squirrel@mail.serc.iisc.ernet.in>    <4874CAE7.80600@linux-foundation.org>    <2282.10.16.10.158.1215615048.squirrel@mail.serc.iisc.ernet.in>    <4874D232.800@linux-foundation.org>    <2323.10.16.10.158.1215617532.squirrel@mail.serc.iisc.ernet.in> <2379.10.16.10.158.1215618203.squirrel@mail.serc.iisc.ernet.in>
In-Reply-To: <2379.10.16.10.158.1215618203.squirrel@mail.serc.iisc.ernet.in>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kiran@serc.iisc.ernet.in
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

kiran@serc.iisc.ernet.in wrote:
> Part of the code in mm/objrmap.c which is giving this fault is

This file no longer exists upstream. I know there were several issues with the anonymous rmap code in SLES9 that were fixed in service packs. You really need to talk to the vendor.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
