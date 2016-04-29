Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 962E76B025F
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 05:07:47 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id zy2so159111976pac.1
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 02:07:47 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id c6si15398061pfd.242.2016.04.29.02.07.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Apr 2016 02:07:46 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id p185so13458275pfb.3
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 02:07:46 -0700 (PDT)
Date: Fri, 29 Apr 2016 17:07:42 +0800
From: Minfei Huang <mnghuan@gmail.com>
Subject: Re: [PATCH] Use existing helper to convert "on/off" to boolean
Message-ID: <20160429090742.GA16688@dhcp-128-44.nay.redhat.com>
References: <1461908824-16129-1-git-send-email-mnghuan@gmail.com>
 <20160429080430.GA21977@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160429080430.GA21977@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, labbott@fedoraproject.org, rjw@rjwysocki.net, mgorman@techsingularity.net, vbabka@suse.cz, rientjes@google.com, kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, alexander.h.duyck@redhat.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/29/16 at 10:04P, Michal Hocko wrote:
> On Fri 29-04-16 13:47:04, Minfei Huang wrote:
> > It's more convenient to use existing function helper to convert string
> > "on/off" to boolean.
> 
> But kstrtobool in linux-next only does "This routine returns 0 iff the
> first character is one of 'Yy1Nn0'" so it doesn't know about on/off.
> Or am I missing anything?

Hi, Michal.

Thanks for your reply.

Following is the kstrtobool comment from linus tree, which has explained
that this function can parse "on"/"off" string. Also Kees Cook has
posted such patch to fix this issue as well. So I think it's safe to fix
it.

"
  This routine returns 0 if the first character is one of 'Yy1Nn0', or
  [oO][NnFf] for "on" and "off". Otherwise it will return -EINVAL.  Value
  pointed to by res is updated upon finding a match.
"

  commit 4cc7ecb7f2a60e8deb783b8fbf7c1ae467acb920
  Author: Kees Cook <keescook@chromium.org>
  Date:   Thu Mar 17 14:23:00 2016 -0700
  
      param: convert some "on"/"off" users to strtobool
  
      This changes several users of manual "on"/"off" parsing to use
      strtobool.
  
      Some side-effects:
      - these uses will now parse y/n/1/0 meaningfully too
      - the early_param uses will now bubble up parse errors

Thanks
Minfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
