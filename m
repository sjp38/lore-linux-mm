Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E92B56B010D
	for <linux-mm@kvack.org>; Sun,  5 Jun 2011 09:59:10 -0400 (EDT)
Message-ID: <4DEB8B97.6020605@redhat.com>
Date: Sun, 05 Jun 2011 16:58:47 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
References: <20110601011527.GN19505@random.random> <alpine.LSU.2.00.1105312120530.22808@sister.anvils> <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com> <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com> <4DE60940.1070107@redhat.com> <4DE61A2B.7000008@fnarfbargle.com> <20110601111841.GB3956@zip.com.au> <4DE62801.9080804@fnarfbargle.com> <20110601230342.GC3956@zip.com.au> <4DE8E3ED.7080004@fnarfbargle.com> <4DEB3AE4.8040700@redhat.com> <4DEB8872.2060801@fnarfbargle.com>
In-Reply-To: <4DEB8872.2060801@fnarfbargle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brad Campbell <lists2009@fnarfbargle.com>
Cc: CaT <cat@zip.com.au>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>, netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org

On 06/05/2011 04:45 PM, Brad Campbell wrote:
>> The mailing list might be set not to send your own mails back to you.
>> Check the list archive.
>
>
> Yep, I did that first..
>
> Given the response to previous issues along the same line, it looks a 
> bit like I just remember not to actually use the system in the way 
> that triggers the bug and be happy that 99% of the time the kernel 
> does not panic, but have that lovely feeling in the back of the skull 
> that says "any time now, and without obvious reason the whole machine 
> might just come crashing down"..
>
> I guess it's still better than running Xen or Windows..

Not at all.  Can some networking/netfilter expert look at this?

Please file a bug with all the relevant information in this thread.  If 
you can look for a previous version that worked, that might increase the 
chances of the bug being resolved faster.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
