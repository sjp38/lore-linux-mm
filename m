Received: from mail.lu.unisi.ch ([195.176.178.40] verified)
  by ti-edu.ch (CommuniGate Pro SMTP 5.1.12)
  with ESMTP id 22466553 for linux-mm@kvack.org; Tue, 09 Oct 2007 18:00:18 +0200
Message-ID: <470BA58F.8050907@lu.unisi.ch>
Date: Tue, 09 Oct 2007 18:00:15 +0200
From: Paolo Bonzini <paolo.bonzini@lu.unisi.ch>
Reply-To: bonzini@gnu.org
MIME-Version: 1.0
Subject: Re: [Bug 9138] New: kernel overwrites MAP_PRIVATE mmap
References: <bug-9138-27@http.bugzilla.kernel.org/> <20071009083913.212fb3e3.akpm@linux-foundation.org>
In-Reply-To: <20071009083913.212fb3e3.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bonzini@gnu.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> So can you confirm that this behaviour was not present in 2.6.8 but is
> present in 2.6.20?

Yes.  I also have access to a Debian i686 2.6.22.9 and it shows the bug. 
  Though I am not the one who compiled the kernel on either machine 
(neither the i686 nor the x86-64).

> Would it be possible to prevail upon you to cook up a little standalone
> testcase?  

I already tried to no avail.  I may have more time in november.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
