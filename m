Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 510B66B007E
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 17:21:12 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id dx6so189011829pad.0
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 14:21:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z189si16015134pfb.180.2016.04.29.14.21.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Apr 2016 14:21:11 -0700 (PDT)
Date: Fri, 29 Apr 2016 14:21:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Use existing helper to convert "on/off" to boolean
Message-Id: <20160429142110.b4039a422866754bc914b8b2@linux-foundation.org>
In-Reply-To: <1461908824-16129-1-git-send-email-mnghuan@gmail.com>
References: <1461908824-16129-1-git-send-email-mnghuan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minfei Huang <mnghuan@gmail.com>
Cc: labbott@fedoraproject.org, rjw@rjwysocki.net, mgorman@techsingularity.net, mhocko@suse.com, vbabka@suse.cz, rientjes@google.com, kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, alexander.h.duyck@redhat.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 29 Apr 2016 13:47:04 +0800 Minfei Huang <mnghuan@gmail.com> wrote:

> It's more convenient to use existing function helper to convert string
> "on/off" to boolean.
> 
> ...
>
> --- a/lib/kstrtox.c
> +++ b/lib/kstrtox.c
> @@ -326,7 +326,7 @@ EXPORT_SYMBOL(kstrtos8);
>   * @s: input string
>   * @res: result
>   *
> - * This routine returns 0 iff the first character is one of 'Yy1Nn0', or
> + * This routine returns 0 if the first character is one of 'Yy1Nn0', or

That isn't actually a typo.  "iff" is shorthand for "if and only if". 
ie: kstrtobool() will not return 0 in any other case.

Use of "iff" is a bit pretentious but I guess it does convey some
conceivably useful info.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
