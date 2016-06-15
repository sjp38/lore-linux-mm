Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id A3FEE6B007E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 18:53:24 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id na2so19888653lbb.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 15:53:24 -0700 (PDT)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id e7si12528663wma.24.2016.06.15.15.53.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 15:53:23 -0700 (PDT)
Received: by mail-wm0-x232.google.com with SMTP id m124so44511567wme.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 15:53:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160615154402.d903d57a64377df7ebc77ad9@linux-foundation.org>
References: <201606140353.WeDaHl1M%fengguang.wu@intel.com> <20160613141123.fcb245b6a7fd3199ae8a32d7@linux-foundation.org>
 <CAGXu5jLH+UzOhPfj5VkydHg=ZxbrQHQe6C1C-dbCBzsAmW9M2Q@mail.gmail.com>
 <CAGXu5jJ-ga0pXVtkCFSS6tGnsuhhNxOOguexUU14_4fwa3Uaeg@mail.gmail.com>
 <20160615142628.75bf404e7b48e239759f6994@linux-foundation.org>
 <CAGXu5jLKS=cWJJozFOYyjzNuiBt5GTSBAfZCyFRXh3oVE5QE=g@mail.gmail.com> <20160615154402.d903d57a64377df7ebc77ad9@linux-foundation.org>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 15 Jun 2016 15:53:22 -0700
Message-ID: <CAGXu5jK=XVUs7Lt=GO8fBdgUarMhZ8sdOyYWsOmD+uR0YTqJxA@mail.gmail.com>
Subject: Re: [mel:mm-vmscan-node-lru-v7r3 38/200] slub.c:undefined reference
 to `cache_random_seq_create'
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Mel Gorman <mgorman@suse.de>, Thomas Garnier <thgarnie@google.com>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Jun 15, 2016 at 3:44 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 15 Jun 2016 15:37:48 -0700 Kees Cook <keescook@chromium.org> wrote:
>
>> (Did your gcc-4.4.4 ever build with CONFIG_CC_STACKPROTECTOR enabled?)
>
> I doubt it.  With this compiler I usually just do allmodconfig and
> let it rip.

Heh, okay. In that case, I'll say things are working as intended. :)

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
