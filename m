Date: Wed, 12 Mar 2003 17:19:09 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH 2.5.64-mm5] objrmap fix for nonlinear
Message-ID: <123060000.1047511149@baldur.austin.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0303121814560.3890-100000@dhcp64-226.boston.redhat.com>
References: <Pine.LNX.4.44.0303121814560.3890-100000@dhcp64-226.boston.redha
 t.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: Andrew Morton <akpm@digeo.com>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--On Wednesday, March 12, 2003 18:16:01 -0500 Rik van Riel
<riel@surriel.com> wrote:

> Could I get a copy of that abuse test ? ;))

My abuse test is to take a dual 200Mhz PentiumPro w/ 128M memory and do a
'make -j 50 bzImage' on a kernel tree.  So far it's proven to find some
fairly low-probability races.

Dave

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
