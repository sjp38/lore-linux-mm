Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A39BE6B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 12:47:48 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g202so196228145pfb.3
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 09:47:48 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f9si4610211pad.155.2016.09.09.09.47.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Sep 2016 09:47:47 -0700 (PDT)
Subject: Re: [PATCH] Fix region lost in /proc/self/smaps
References: <1473231111-38058-1-git-send-email-guangrong.xiao@linux.intel.com>
 <57D04192.5070704@intel.com>
 <8b800d72-9b28-237c-47a6-604d98a40315@linux.intel.com>
 <57D1703E.4070504@intel.com>
 <01bcbbe2-5560-ea42-4d75-6ab50c3060d4@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57D2E7B1.40201@intel.com>
Date: Fri, 9 Sep 2016 09:47:45 -0700
MIME-Version: 1.0
In-Reply-To: <01bcbbe2-5560-ea42-4d75-6ab50c3060d4@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <guangrong.xiao@linux.intel.com>, pbonzini@redhat.com, akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com
Cc: gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com

On 09/09/2016 01:19 AM, Xiao Guangrong wrote:
> 
> Yes. I was talking the case as follows:
>    1: read() #1: prints vma-A(0x1000 -> 0x2000)
>    2: unmap vma-A(0x1000 -> 0x2000)
>    3: create vma-B(0x80 -> 0x3000) on other file with different permission
>       (w, r, x)
>    4: read #2: prints vma-B(0x2000 -> 0x3000)
> 
> Then userspace will get just a portion of vma-B. well, maybe it is not
> too bad. :)

Yeah, I think this is the way to go.  Feel free to add my ack.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
