Subject: Re: all processes waiting in TASK_UNINTERRUPTIBLE state
Message-ID: <OF29D2C834.F627AA03-ON85256A77.0050F2F6@pok.ibm.com>
From: "Bulent Abali" <abali@us.ibm.com>
Date: Tue, 26 Jun 2001 10:47:12 -0400
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>


>> I am running in to a problem, seemingly a deadlock situation, where
almost
>> all the processes end up in the TASK_UNINTERRUPTIBLE state.   All the
>
>could you try to reproduce with this patch applied on top of
>2.4.6pre5aa1 or 2.4.6pre5 vanilla?

Andrea,
I would like try your patch but so far I can trigger the bug only when
running TUX 2.0-B6 which runs on 2.4.5-ac4.  /bulent



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
