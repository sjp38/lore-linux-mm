Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: [PATCH 2.5.41-mm1] new snapshot of shared page tables
Date: Wed, 9 Oct 2002 23:04:47 -0400
References: <228900000.1034197657@baldur.austin.ibm.com>
In-Reply-To: <228900000.1034197657@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200210092304.47577.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On October 9, 2002 05:07 pm, Dave McCracken wrote:
> Here's the latest shared page table patch.  Changes are mostly cleanups,
> with the added feature that shared page tables are now a config option.
> This means the patch should build on other architectures (this is
> untested).
>
> At Andrew Morton's request, I've moved my development base to the -mm line.

After realizing (thanks Dave) that kmail 3.03 has a bug saving multipart/mixed 
mime messages, I was able to use uudeview to extract a clean patch, and build
kernel which boot fine.  Thats the good news.

When I try to start kde 3.03 on an up to date debian sid (X 4.2 etc) kde fails to start.
It complains that ksmserver cannot be started.  Same setup works with 41-mm1.

Know this is not a meaty report.  With X4.2 I have not yet figgered out how to get 
more debug messages (the log from xstart is anemic) nor is there anything in
messages, kern.log or on the serial console.  The box is a K6-III 400 on a via MVP3
chipset.

What other info can I gather?

Ed Tomlinson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
