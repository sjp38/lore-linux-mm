Message-ID: <3BBB7F5F.9040806@brsat.com.br>
Date: Wed, 03 Oct 2001 18:13:03 -0300
From: Roberto Orenstein <roberto@brsat.com.br>
Reply-To: roberto@brsat.com.br
MIME-Version: 1.0
Subject: weird memshared value
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: cr@sap.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Cristoph,

Guess found a bug in the MemShared value that shows up in /proc/meminfo.
At least it's pretty weird :)

After a cp kernel_tree new_tree, together with make bzImage, got the 
following number:

MemShared:    4294966488 kB

My system has only 128MB. P-III, kernel 2.4.9-ac16.
It doesn't harm, but it's way far from my system mem.

Any idea?

thanx

Roberto

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
