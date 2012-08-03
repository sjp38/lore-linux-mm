Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 32B966B0044
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 17:41:09 -0400 (EDT)
Received: by wibhm6 with SMTP id hm6so5540635wib.8
        for <linux-mm@kvack.org>; Fri, 03 Aug 2012 14:41:07 -0700 (PDT)
Message-ID: <501C458E.7050000@gmail.com>
Date: Fri, 03 Aug 2012 23:41:34 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC v2 1/7] hashtable: introduce a small and naive hashtable
References: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com> <1344003788-1417-2-git-send-email-levinsasha928@gmail.com> <20120803171515.GH15477@google.com> <501C407D.9080900@gmail.com> <20120803213017.GK15477@google.com>
In-Reply-To: <20120803213017.GK15477@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org

On 08/03/2012 11:30 PM, Tejun Heo wrote:
> Hello,
> 
> On Fri, Aug 03, 2012 at 11:19:57PM +0200, Sasha Levin wrote:
>>> Is this supposed to be embedded in struct definition?  If so, the name
>>> is rather misleading as DEFINE_* is supposed to define and initialize
>>> stand-alone constructs.  Also, for struct members, simply putting hash
>>> entries after struct hash_table should work.
>>
>> It would work, but I didn't want to just put them in the union since
>> I feel it's safer to keep them in a separate struct so they won't be
>> used by mistake,
> 
> Just use ugly enough pre/postfixes.  If the user still accesses that,
> it's the user's fault.

I forgot to comment on that one, sorry.

If we put hash entries after struct hash_table we don't take the bits field size into account, or did I miss something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
