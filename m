Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m09JuQse004776
	for <linux-mm@kvack.org>; Wed, 9 Jan 2008 14:56:26 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m09JrwfM139766
	for <linux-mm@kvack.org>; Wed, 9 Jan 2008 14:54:36 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m09Jrwfd020958
	for <linux-mm@kvack.org>; Wed, 9 Jan 2008 14:53:58 -0500
Subject: Re: [PATCH 10/10] x86: Unify percpu.h
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0801091130420.11317@schroedinger.engr.sgi.com>
References: <20080108211023.923047000@sgi.com>
	 <20080108211025.293924000@sgi.com> <1199906905.9834.101.camel@localhost>
	 <Pine.LNX.4.64.0801091130420.11317@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 09 Jan 2008 11:53:50 -0800
Message-Id: <1199908430.9834.104.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: travis@sgi.com, Andrew Morton <akpm@linux-foundation.org>, mingo@elte.hu, Andi Kleen <ak@suse.de>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, tglx@linutronix.de, mingo@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 2008-01-09 at 11:31 -0800, Christoph Lameter wrote:
> Well this is only the first patchset. The next one will unify this even 
> more (and make percpu functions work consistent between the two arches) 
> but it requires changes to the way the %gs register is used in 
> x86_64. So we only do the simplest thing here to have one file to patch 
> against later.

Then I really think this particular patch belongs in that other patch
set.  Here, it makes very little sense, and it's on the end anyway.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
