Date: Fri, 21 Nov 2008 15:24:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Make the get_user_pages interruptible
In-Reply-To: <604427e00811201403k26e4bf93tdb2dee9506756a82@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.0811211520450.16413@chino.kir.corp.google.com>
References: <604427e00811201403k26e4bf93tdb2dee9506756a82@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Paul Menage <menage@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 20 Nov 2008, Ying Han wrote:

> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index b483f39..f2a5cac 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1795,6 +1795,7 @@ extern void flush_signals(struct task_struct *);
>  extern void ignore_signals(struct task_struct *);
>  extern void flush_signal_handlers(struct task_struct *, int force_default);
>  extern int dequeue_signal(struct task_struct *tsk, sigset_t *mask, siginfo_t
> +extern int sigkill_pending(struct task_struct *tsk);
> 
>  static inline int dequeue_signal_lock(struct task_struct *tsk, sigset_t *mask
>  {

I can't git apply this because it appears as though your email client has 
truncated long lines (see dequeue_signal above).

Your headers look like you're using the gmail GUI to send patches, and 
that client has its own section in Documentation/email-clients.txt.  If 
the instructions don't happen to work for you, please fix that section 
once you've troubleshooted the problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
