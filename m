Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id TAA16375
	for <linux-mm@kvack.org>; Tue, 24 Sep 2002 19:54:48 -0700 (PDT)
Message-ID: <3D912577.160421F8@digeo.com>
Date: Tue, 24 Sep 2002 19:54:47 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.38-mm2 pdflush_list
References: <20020925022324.GP6070@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> ...
> There's a NULL in this circular list:
> 

The only way I can see this happen is if someone sprayed out
a bogus wakeup.  Are you using preempt (or software suspend??)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
