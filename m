Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 52E8C6B0032
	for <linux-mm@kvack.org>; Thu, 30 May 2013 13:39:34 -0400 (EDT)
Message-ID: <51A78EC4.4080703@intel.com>
Date: Thu, 30 May 2013 10:39:16 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: sparse: use __aligned() instead of manual padding
 in mem_section
References: <1369869279-20155-1-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1369869279-20155-1-git-send-email-cody@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On 05/29/2013 04:14 PM, Cody P Schafer wrote:
> Instead of leaving a trap for the next person who comes along and wants
> to add something to mem_section, add an __aligned() and remove the
> manual padding added for MEMCG.

It doesn't need to be aligned technically.  It needs to be a power-of-2:

http://lkml.indiana.edu/hypermail/linux/kernel/1205.2/03077.html

I'd be quite happy for someone to resurrect that patch, though.  We need
a big fat comment in there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
