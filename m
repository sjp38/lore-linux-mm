From: Mark_H_Johnson@Raytheon.com
Subject: Re: Running out of memory in 1 easy step
Message-ID: <OF27377286.F79B9CAC-ON8625695B.005CBBBE@hou.us.ray.com>
Date: Fri, 15 Sep 2000 11:53:48 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: hahn@coffee.psychology.mcmaster.ca
Cc: linux-mm@kvack.org, Wichert Akkerman <wichert@cistron.nl>
List-ID: <linux-mm.kvack.org>

I understand about the granularity issue - I was concerned about "extra
pages" above the granularity of allocation.
Thanks also for the sample program - we'll try it with our sample sizes to
make sure we really understand what's being used.
--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
