Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 16DE16B007E
	for <linux-mm@kvack.org>; Sat, 30 Apr 2016 00:47:25 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id xm6so173190262pab.3
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 21:47:25 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id rz3si22057906pac.196.2016.04.29.21.47.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Apr 2016 21:47:23 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id r187so16731569pfr.2
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 21:47:23 -0700 (PDT)
Date: Sat, 30 Apr 2016 12:47:16 +0800
From: Minfei Huang <mnghuan@gmail.com>
Subject: Re: [PATCH] Use existing helper to convert "on/off" to boolean
Message-ID: <20160430044716.GA18250@dhcp-128-44.nay.redhat.com>
References: <1461908824-16129-1-git-send-email-mnghuan@gmail.com>
 <20160429142110.b4039a422866754bc914b8b2@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160429142110.b4039a422866754bc914b8b2@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: labbott@fedoraproject.org, rjw@rjwysocki.net, mgorman@techsingularity.net, mhocko@suse.com, vbabka@suse.cz, rientjes@google.com, kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/29/16 at 02:21P, Andrew Morton wrote:
> On Fri, 29 Apr 2016 13:47:04 +0800 Minfei Huang <mnghuan@gmail.com> wrote:
> 
> > It's more convenient to use existing function helper to convert string
> > "on/off" to boolean.
> > 
> > ...
> >
> > --- a/lib/kstrtox.c
> > +++ b/lib/kstrtox.c
> > @@ -326,7 +326,7 @@ EXPORT_SYMBOL(kstrtos8);
> >   * @s: input string
> >   * @res: result
> >   *
> > - * This routine returns 0 iff the first character is one of 'Yy1Nn0', or
> > + * This routine returns 0 if the first character is one of 'Yy1Nn0', or
> 
> That isn't actually a typo.  "iff" is shorthand for "if and only if". 
> ie: kstrtobool() will not return 0 in any other case.
> 
> Use of "iff" is a bit pretentious but I guess it does convey some
> conceivably useful info.
> 

Got it. Thanks for your explanation.

Thanks
Minfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
