Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 193E66B02B4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 16:35:38 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id e79so92387244ioi.6
        for <linux-mm@kvack.org>; Mon, 22 May 2017 13:35:38 -0700 (PDT)
Received: from nm26.bullet.mail.ne1.yahoo.com (nm26.bullet.mail.ne1.yahoo.com. [98.138.90.89])
        by mx.google.com with ESMTPS id j201si19427199ioe.2.2017.05.22.13.35.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 13:35:37 -0700 (PDT)
Subject: Re: [PATCH] LSM: Make security_hook_heads a local variable.
References: <20170520085147.GA4619@kroah.com>
 <1495365245-3185-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170522140306.GA3907@infradead.org>
 <d98f4cd5-3f21-3f7b-2842-12b9a009e453@schaufler-ca.com>
 <d25e2fd3-da11-4ec0-8edc-f1327c04fa6e@huawei.com>
From: Casey Schaufler <casey@schaufler-ca.com>
Message-ID: <af26581e-6f5a-3fc2-dc58-8376328a0ad9@schaufler-ca.com>
Date: Mon, 22 May 2017 13:32:59 -0700
MIME-Version: 1.0
In-Reply-To: <d25e2fd3-da11-4ec0-8edc-f1327c04fa6e@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, Christoph Hellwig <hch@infradead.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-security-module@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>, James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>

On 5/22/2017 12:50 PM, Igor Stoppa wrote:
> On 22/05/17 18:09, Casey Schaufler wrote:
>> On 5/22/2017 7:03 AM, Christoph Hellwig wrote:
> [...]
>
>>> But even with those we can still chain
>>> them together with a list with external linkage.
>> I gave up that approach in 2012. Too many unnecessary calls to
>> null functions, and massive function vectors with a tiny number
>> of non-null entries. From a data structure standpoint, it was
>> just wrong. The list scheme is exactly right for the task at
>> hand.
> I understand this as a green light, for me to continue with the plan of
> using LSM Hooks as example for making dynamically allocated data become
> read-only, using also Tetsuo's patch (thanks, btw).

I still don't like the assumption that a structure of
N elements can be assumed to be the same as an array
of N elements. Putting on my hardening hat, however, I
like the smalloc() solution to keeping the hook lists
safe, so I am willing to swallow the objection to using
offsets to address the existing exposure.

>
> Is that correct?
>
> ---
> thanks, igor
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
