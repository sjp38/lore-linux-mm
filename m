Subject: Re: [PATCH] Prevent OOM from killing init
From: Michael Peddemors <michael@linuxmagic.com>
In-Reply-To: <20010322142831.A929@owns.warpcore.org>
References: <3AB9313C.1020909@missioncriticallinux.com>
	<Pine.LNX.4.21.0103212047590.19934-100000@imladris.rielhome.conectiva>
	<20010322124727.A5115@win.tue.nl>  <20010322142831.A929@owns.warpcore.org>
Content-Type: text/plain
Date: 22 Mar 2001 17:31:57 -0800
Mime-Version: 1.0
Message-Id: <20010323014830Z131175-15394+161@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Clouse <stephenc@theiqgroup.com>
Cc: Guest section DW <dwguest@win.tue.nl>, Rik van Riel <riel@conectiva.com.br>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Here, Here.. killing qmail on a server who's sole task is running mail doesn't seem to make much sense either..

> > Clearly, Linux cannot be reliable if any process can be killed

> > at any moment. I am not happy at all with my recent experiences.
> 
> Really the whole oom_kill process seems bass-ackwards to me.  I can't in my mind
> logically justify annihilating large-VM processes that have been running for 
> days or weeks instead of just returning ENOMEM to a process that just started 
> up.
> 
> We run Oracle on a development box here, and it's always the first to get the
> axe (non-root process using 70-80 MB VM).  Whenever someone's testing decides to 
> run away with memory, I usually spend the rest of the day getting intimate with
> the backup files, since SIGKILLing random Oracle processes, as you might have
> guessed, has a tendency to rape the entire database.

-- 
"Catch the Magic of Linux..."
--------------------------------------------------------
Michael Peddemors - Senior Consultant
LinuxAdministration - Internet Services
NetworkServices - Programming - Security
WizardInternet Services http://www.wizard.ca
Linux Support Specialist - http://www.linuxmagic.com
--------------------------------------------------------
(604)589-0037 Beautiful British Columbia, Canada

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
