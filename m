Return-Path: <SRS0=llCs=VE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,GAPPY_SUBJECT,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9107BC48BDE
	for <linux-mm@archiver.kernel.org>; Sun,  7 Jul 2019 16:15:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B6982133D
	for <linux-mm@archiver.kernel.org>; Sun,  7 Jul 2019 16:15:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TWOzKVht"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B6982133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B93536B000A; Sun,  7 Jul 2019 12:15:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6AA88E0006; Sun,  7 Jul 2019 12:15:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A7F1C8E0001; Sun,  7 Jul 2019 12:15:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 86A4E6B000A
	for <linux-mm@kvack.org>; Sun,  7 Jul 2019 12:15:21 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id q26so8186193ioi.10
        for <linux-mm@kvack.org>; Sun, 07 Jul 2019 09:15:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HPjV5oIkkTKWgs8bzuMudxn+m/34k9ESgX/d9EjKBY4=;
        b=o9Mo43tqdpbqgRhzRHLbgBLyp2f1sQkM9KTLfE+kctgWSIm3ly/yKt+UmYpIeKfKH8
         LEdYyrw1Q11l/R+EdjBuOY+zF8L5nIJ+BpD5p06BGSAmVMzwhA0bXzSPazjo9wPNutRw
         iLuisAwLU1cjEdJa9rPmznJi9A+xfYaGJ9YNpXZZVikTsNlFEyvRzHdI53kKzVDk5O7X
         IDsPIWIi2mSmc9OhtuximQ1rf6z4xtLpWC41h+lfMFacd+LSIurmPcjq6+2plQ8FEYJb
         oE9qsuOSZWaYbZFA29Scfy4Hyi381isn70BdM8Vi55WkFRLB+3lRutH+s5Ui0X2tH2DM
         tdCQ==
X-Gm-Message-State: APjAAAXpgRyDTeK9ChmDYSeDJO3uNpTb9K4IryllKTu3T56wvgXyaifS
	5uEGLYFtTMs4xnMmYvZeQB2bzD6SWl492QfCmibd4R5hVwRd6seoOAjnot7JserHokRaLZvGB4U
	kOM1m9ZgpNAvFSMwQMqHN3XY1W0kyWM+Kfowozp7Q6O7Rov1mrbxr4KgoOdiDg+kdgA==
X-Received: by 2002:a5d:9dc7:: with SMTP id 7mr14578878ioo.237.1562516121221;
        Sun, 07 Jul 2019 09:15:21 -0700 (PDT)
X-Received: by 2002:a5d:9dc7:: with SMTP id 7mr14578840ioo.237.1562516120627;
        Sun, 07 Jul 2019 09:15:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562516120; cv=none;
        d=google.com; s=arc-20160816;
        b=r4PXE/FiO9/Vc2xNSl3FLnTp7H6+8sGIAiYwio4i6DphxzhLuFCgA0akn2bRGwUXNf
         kIzEhK5SzIbllmzTfGlYQzIGjoBYgVI+2desOZwaYjv9RrTpe07Q8Y2TarCSMgHe0xqZ
         9nvfinSaJz7lHF1kC7MI7I/qoIHWAy5hAJYTuku3MTEIUo880FvzRFe2YDIXMcNiVeWi
         j4uTvcMvObcP0vRZYzhs3W8KJX+F/sPXQdWvXaSF1Aw7weg25iBJCjwPMd7FAYCJPmX/
         19ouBtyZZuOZQV5h2OKA0HT71oa1VkkUJZS/Kwe9XfedYd233DQN9CG6P38hGDJWxD7q
         G0Gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HPjV5oIkkTKWgs8bzuMudxn+m/34k9ESgX/d9EjKBY4=;
        b=ru5sgEKJVrANH7K9Mx8LzcBeBKiPuSXPdsXs13isOk8rezH79FYS6BNyG3scROLyDV
         R9enZNfEqWgE7SQkId5qVJbf9ZJdX9rB9B7XntFzwuRsbhHTqXAUV4Kjrp17Eu8o3UXw
         pLjQUt06g/pdM4Ukk1r+YEImPfJliv2/tBH/g0az4dIUPdPHU9NrwxWnBgeB6lT8DUJC
         aXaYg3HFHRRSTajDeYFKerLI8GiXfN0lU7Gf5RZUkC3za1BMbldxdik66jLDIh17M8ov
         DcvJDiBEuZik1F+0S4arMeNF6CIRCYqrN6lwpWwVNktzFvpZV63uBIi4ihhA9foxmSfC
         PW6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TWOzKVht;
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e18sor10163639iot.134.2019.07.07.09.15.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 07 Jul 2019 09:15:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TWOzKVht;
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HPjV5oIkkTKWgs8bzuMudxn+m/34k9ESgX/d9EjKBY4=;
        b=TWOzKVhtLNsWGzSmCaNZ6b/RZ3+Q0QunAQWRvFiNWs1RisWJjT0tbEfSaH4szCiWfq
         82uSZ4Xvjt6zWF5p026f32NIV/sy/6hd5AsJxTSsxrgwzMPdbEP44HkqaP+B9Q8QLvGY
         ECPuLqNdhl4Y6DYcbNZMIdDn10XiRwz+pYUe3zKKKxaTqkouVwh3CpK/NeQ4lfy4Qzci
         /LwMAd/E0YTYFdoEsh6AH3BYOxqZKfKOUnfH6U1WpPC+HbFE6z/yYoBAGaPxrM2iA4PE
         RA7UnwRtCLj3ZAlGqYs/vpvDG83e6mXKuSofbiuIMkue5dKOkbDzFhtM4/9W0v3YYfRI
         BqWA==
X-Google-Smtp-Source: APXvYqyUye9cz+0n15zQ4gOArOoK5kXFrcrLZZSEtAMpudDveLjSJuBRU+UsJPJBC8N4qob10YrUs4SNp8kqivMgQUg=
X-Received: by 2002:a6b:e20a:: with SMTP id z10mr7315185ioc.76.1562516120337;
 Sun, 07 Jul 2019 09:15:20 -0700 (PDT)
MIME-Version: 1.0
References: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
 <1562410493-8661-12-git-send-email-s.mesoraca16@gmail.com> <CAG48ez0uFX4AniOk1W0Vs6j=7Q5QfSFQTrBBzC2qL2bpWn_yCg@mail.gmail.com>
In-Reply-To: <CAG48ez0uFX4AniOk1W0Vs6j=7Q5QfSFQTrBBzC2qL2bpWn_yCg@mail.gmail.com>
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Date: Sun, 7 Jul 2019 18:15:09 +0200
Message-ID: <CAJHCu1K-x1tCehO1CxTf9ZzVKLh44dE9hwWWSCxnW1A4SHX=kQ@mail.gmail.com>
Subject: Re: [PATCH v5 11/12] S.A.R.A.: /proc/*/mem write limitation
To: Jann Horn <jannh@google.com>
Cc: kernel list <linux-kernel@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Brad Spengler <spender@grsecurity.net>, 
	Casey Schaufler <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>, 
	Kees Cook <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Thomas Gleixner <tglx@linutronix.de>, James Morris <jmorris@namei.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Jann Horn <jannh@google.com> wrote:
>
> On Sat, Jul 6, 2019 at 12:55 PM Salvatore Mesoraca
> <s.mesoraca16@gmail.com> wrote:
> > Prevent a task from opening, in "write" mode, any /proc/*/mem
> > file that operates on the task's mm.
> > A process could use it to overwrite read-only memory, bypassing
> > S.A.R.A. restrictions.
> [...]
> > +static void sara_task_to_inode(struct task_struct *t, struct inode *i)
> > +{
> > +       get_sara_inode_task(i) = t;
>
> This looks bogus. Nothing is actually holding a reference to `t` here, right?

I think you are right, I should probably store the PID here.

> > +}
> > +
> >  static struct security_hook_list data_hooks[] __lsm_ro_after_init = {
> >         LSM_HOOK_INIT(cred_prepare, sara_cred_prepare),
> >         LSM_HOOK_INIT(cred_transfer, sara_cred_transfer),
> >         LSM_HOOK_INIT(shm_alloc_security, sara_shm_alloc_security),
> > +       LSM_HOOK_INIT(task_to_inode, sara_task_to_inode),
> >  };
> [...]
> > +static int sara_file_open(struct file *file)
> > +{
> > +       struct task_struct *t;
> > +       struct mm_struct *mm;
> > +       u16 sara_wxp_flags = get_current_sara_wxp_flags();
> > +
> > +       /*
> > +        * Prevent write access to /proc/.../mem
> > +        * if it operates on the mm_struct of the
> > +        * current process: it could be used to
> > +        * bypass W^X.
> > +        */
> > +
> > +       if (!sara_enabled ||
> > +           !wxprot_enabled ||
> > +           !(sara_wxp_flags & SARA_WXP_WXORX) ||
> > +           !(file->f_mode & FMODE_WRITE))
> > +               return 0;
> > +
> > +       t = get_sara_inode_task(file_inode(file));
> > +       if (unlikely(t != NULL &&
> > +                    strcmp(file->f_path.dentry->d_name.name,
> > +                           "mem") == 0)) {
>
> This should probably at least have a READ_ONCE() somewhere in case the
> file concurrently gets renamed?

My understanding here is that /proc/$pid/mem files cannot be renamed.
t != NULL implies we are in procfs.
Under these assumptions I think that that code is fine.
Am I wrong?

> > +               get_task_struct(t);
> > +               mm = get_task_mm(t);
> > +               put_task_struct(t);
>
> Getting and dropping a reference to the task_struct here is completely
> useless. Either you have a reference, in which case you don't need to
> take another one, or you don't have a reference, in which case you
> also can't take one.

Absolutely agree.

> > +               if (unlikely(mm == current->mm))
> > +                       sara_warn_or_goto(error,
> > +                                         "write access to /proc/*/mem");
>
> Why is the current process so special that it must be protected more
> than other processes? Is the idea here to rely on other protections to
> protect all other tasks? This should probably come with a comment that
> explains this choice.

Yes, I should have spent some more words here.
Access to /proc/$pid/mem from other processes is already regulated by
security_ptrace_access_check (i.e. Yama).
Unfortunately, that hook is ignored when "mm == current->mm".
It seems that there is some user-space software that relies on /proc/self/mem
being writable (cfr. commit f511c0b17b08).

Thank you for your suggestions.

