Message-ID: <3AB93C02.5030109@missioncriticallinux.com>
Date: Wed, 21 Mar 2001 18:40:50 -0500
From: "Patrick O'Rourke" <orourke@missioncriticallinux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Prevent OOM from killing init
References: <3AB9313C.1020909@missioncriticallinux.com> <3AB9352A.71E42C38@inet.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eli Carter <eli.carter@inet.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Eli Carter wrote:

> Having not looked at the code... Why not "if( p->pid > 1 )"?  (Or can
> p->pid can be negative?!, um, typecast to unsigned...)

I simply mirrored the check done in do_exit():

	if (tsk->pid == 1)
		panic("Attempted to kill init!");

Since PID_MAX is 32768 I do not believe pids can be negative.

I suppose one could make an argument for skipping "daemons", i.e.
pids below 300 (see the get_pid() function in kernel/fork.c), but
I think that is a larger issue.

Pat

-- 
Patrick O'Rourke
978.606.0236
orourke@missioncriticallinux.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
