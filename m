From: "Joseph D. Wagner" <wagnerjd@prodigy.net>
Subject: RE: How to study memory leakage
Date: Tue, 11 Feb 2003 10:10:14 -0600
Message-ID: <000001c2d1e8$11409c20$b5425aa6@joe>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
In-Reply-To: <200302110939.PAA09314@brahma.roc.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: shajupt@qpackets.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> System is becoming slow after some user space
> programs are run and the memory usage displayed
> also increasing
>
> is their any known procedure or tools to study
> the memory leakage both in user-space and kernel-space

1) Monitor current memory usage taking special care to note current memory statistics
2) Start the suspect program
3) Do stuff
4) Quit the suspect
5) Check back with memory statistics; they should be the same as when you started the program.  If you're missing memory, this is the confirmed leak.

Step 5 isn't as easy as it looks.  The memory leak may only be occurring in a particular part of the program.  For example, if you have a Word Processor, the leak may occur only after executing the Find/Replace functions, not simply from running the program.

Yeah, there are tools out there that make this a lot easier, but I don't know where these tools are on Linux.

Joseph Wagner

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
