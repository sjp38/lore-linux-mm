Subject: Re: Locked memory questions
References: <OF55A69DFC.F1913EBB-ON862569DC.00556518@hou.us.ray.com>
From: Christoph Rohland <cr@sap.com>
In-Reply-To: <OF55A69DFC.F1913EBB-ON862569DC.00556518@hou.us.ray.com>
Message-ID: <m31ytmysf7.fsf@linux.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: 30 Jan 2001 10:20:57 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark_H_Johnson@Raytheon.com
Cc: linux-mm@kvack.org, Stanley_R_Allen-NR@Raytheon.com
List-ID: <linux-mm.kvack.org>

Mark_H_Johnson@Raytheon.com writes:

> I was surprised by a reference in the latest kernel traffic
> (http://kt.linuxcare.com/kernel-traffic/latest.epl) to a VM problem with
> large locked memory regions. I read linux-mm on a daily basis, but didn't
> see this particular discussion go by. 

Was this the database lockup with locked SYSV shareed memory segments?
This was not discussed a lot but fixed easily. It was a bad
implementation in shmem.c

Greetings
                Christoph

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
