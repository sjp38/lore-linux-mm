Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA07765
	for <linux-mm@kvack.org>; Sun, 19 Jan 2003 14:03:27 -0800 (PST)
Date: Sun, 19 Jan 2003 14:05:08 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.59-mm2
Message-Id: <20030119140508.7ff347d5.akpm@digeo.com>
In-Reply-To: <3014AAAC8E0930438FD38EBF6DCEB5647D149C@fmsmsx407.fm.intel.com>
References: <3014AAAC8E0930438FD38EBF6DCEB5647D149C@fmsmsx407.fm.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Nakajima, Jun" <jun.nakajima@intel.com>
Cc: arjanv@redhat.com, linux-mm@kvack.org, nitin.a.kamble@intel.com, asit.k.mallick@intel.com, sunil.saxena@intel.com
List-ID: <linux-mm.kvack.org>

"Nakajima, Jun" <jun.nakajima@intel.com> wrote:
>
> My point was that doing in user mode cannot justify wasting CPUs cycles
> for not good reasons.

Performing this function in userspace means that we can implement more
effective algorithms, more configurability and perhaps better monitoring - so
on machines which need it, the overhead could well be more than reclaimed.

And we can work on the overhead.  Perhaps add a lightweight alternative to
/proc/interrupts, and change the IRQ affinity setting code so that it merely
places some settings into memory, and those are actually acted upon when the
next interrupt occurs (should be able to do this locklessly).

Given that your new algorithm requires granularity on the order of a second
(this is good!), Arjan's approach is very attractive indeed.

And it should be pretty easy to get the implementation working on other
architectures.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
