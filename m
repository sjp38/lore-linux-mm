Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id NAA18042
	for <linux-mm@kvack.org>; Mon, 3 Feb 2003 13:52:33 -0800 (PST)
Date: Mon, 3 Feb 2003 13:47:19 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH 2.5.59-mm6] Speed up task exit
Message-Id: <20030203134719.0a416c3b.akpm@digeo.com>
In-Reply-To: <64880000.1043786464@baldur.austin.ibm.com>
References: <64880000.1043786464@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave McCracken <dmccr@us.ibm.com> wrote:
>
> 
> Andrew, this builds on my first patch eliminating the page_table_lock
> during page table cleanup on exit.

Sorry David, I just haven't had time to play with this.  I did some quick
testing on uniprocessor shell-script-intensive loads and saw no bottom-line
change at all.

What load did you test with?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
