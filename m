Date: Sat, 12 Apr 2003 21:32:05 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.67-mm2
Message-Id: <20030412213205.4bcbe1d8.akpm@digeo.com>
In-Reply-To: <200304130422.h3D4M6XY031187@sith.maoz.com>
References: <200304130354.h3D3slbp031124@sith.maoz.com>
	<200304130422.h3D4M6XY031187@sith.maoz.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Hall <jhall@maoz.com>
Cc: felipe_alfaro@linuxmail.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jeremy Hall <jhall@maoz.com> wrote:
>
> ah, here we go
> 
> BUG(); line 907 of mm/slab.c
> 

Yup, it looks like the lockmeter patch has borked the preempt_count when
CONFIG_LOCKMETER=n.  Sorry, I didn't test it with preempt enabled.

I'll fix that up.  Meanwhile you can revert the lockmeter patch or disable
preemption.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
