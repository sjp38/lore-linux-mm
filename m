Date: 29 Dec 2001 12:33:25 -0000
Message-ID: <20011229123325.32215.qmail@mailweb9.rediffmail.com>
MIME-Version: 1.0
From: "amey d inamdar" <iamey@rediffmail.com>
Reply-To: "amey d inamdar" <iamey@rediffmail.com>
Subject: additional bit in task & page struct
Content-type: text/plain;
	charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi...
   I want to add my own bit (a #define PG_MYBIT) similar to into the flags in task_struct as defined in linux v2.4.4 in sched.h which is defined as:

unsigned long flag; /*per process flags */ 

   I want a free #define where I can define the process specific flag like PG_EXITING, PG_STARTING.

   Similarly, I also want to add my own bit into the flags in the _page struct_ wherein I can establish the state of a particular page.
  
   Using this my program wants to distinguish between some privileged pages of a process (privileged for my program which serves them..) from other processes and pages.

   Please tell me which #define can I use to do this in both the structures.
  
   Thanking you in advance,
 
   Amey. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
