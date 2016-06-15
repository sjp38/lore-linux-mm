Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 362196B007E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 19:10:17 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id d71so56952536ith.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 16:10:17 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0067.hostedemail.com. [216.40.44.67])
        by mx.google.com with ESMTPS id e77si15295974itd.33.2016.06.15.16.10.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 16:10:16 -0700 (PDT)
Message-ID: <1466032209.19647.20.camel@perches.com>
Subject: Re: [PATCH v3 0/4] Introduce the latent_entropy gcc plugin
From: Joe Perches <joe@perches.com>
Date: Wed, 15 Jun 2016 16:10:09 -0700
In-Reply-To: <CAGXu5jJH2FNenOpAE3Rqh8q=s01sbHmf=QobT98u4h=anjRubw@mail.gmail.com>
References: <20160615001754.f9e986cf961d1466f5e086dc@gmail.com>
	 <CAGXu5jK-QVhbuOnNENq9PesPTdPCnbgODzb0qn=q4ZMS0-ndBA@mail.gmail.com>
	 <20160615223952.f3a4ece452b15c62babf4629@gmail.com>
	 <CAGXu5jJH2FNenOpAE3Rqh8q=s01sbHmf=QobT98u4h=anjRubw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Emese Revfy <re.emese@gmail.com>, Greg KH <gregkh@linuxfoundation.org>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kbuild <linux-kbuild@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Al Viro <viro@zeniv.linux.org.uk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, bart.vanassche@sandisk.com, "David S.
 Miller" <davem@davemloft.net>

On Wed, 2016-06-15 at 16:01 -0700, Kees Cook wrote:
> On Wed, Jun 15, 2016 at 1:39 PM, Emese Revfy <re.emese@gmail.com> wrote:
> > On Wed, 15 Jun 2016 11:55:44 -0700 Kees Cook <keescook@chromium.org> wrote:
> > >  The limit on the length of lines is 80 columns and this is a strongly
> > >  preferred limit.
> > I think the code looks worse when it is truncated to 80 columns but
> > I'll do it and resend the patches.
> Yup, I understand your concerns, but since we're optimizing for
> readability by a larger audience that has agreed to the guidelines in
> CodingStyle, this is what we get. :)
> 
> One area I'm unclear on with kernel coding style, though, is if
> splitting all the stuff prior to function name onto a separate line is
> "acceptable", since that solves most of the long lines where
> __latent_entropy has been added. For example, I don't know which is
> better:
> 
> All on one line (gmail may split this, but my intention is all one line):
> 
> static __latent_entropy void rcu_process_callbacks(struct
> softirq_action *unused)
> 
> Types and attributes on a separate line:
> 
> static __latent_entropy void
> rcu_process_callbacks(struct softirq_action *unused)
> 
> All arguments on the next line:
> 
> static __latent_entropy void rcu_process_callbacks(
>                                                           struct
> softirq_action *unused)
> 
> 
> Greg, do you have a better sense of how to split (or not split) these
> kinds of long lines?

Another option is to add __latent_entropy the same way most
__printf uses are done - on a separate line before the function

__latent_entropy
static void foo(...)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
