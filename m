Received: by gv-out-0910.google.com with SMTP id l14so1492724gvf.19
        for <linux-mm@kvack.org>; Tue, 19 Aug 2008 02:49:04 -0700 (PDT)
Message-ID: <48AA970D.5050403@gmail.com>
Date: Tue, 19 Aug 2008 11:49:01 +0200
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] mm_owner: fix cgroup null dereference
References: <1218745013-9537-1-git-send-email-jirislaby@gmail.com> <48A49C78.7070100@linux.vnet.ibm.com> <48A9E82E.3060009@gmail.com> <48AA4003.5080300@linux.vnet.ibm.com>
In-Reply-To: <48AA4003.5080300@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 08/19/2008 05:37 AM, Balbir Singh wrote:
> Could you please help me with the steps to reproduce the problem.  I don't seem
> to be hitting the mm->owner changed callback. I did have a test case for it when
> I developed mm->owner functionality, but it does not trigger an oops for me.

I have no idea. My config is at:
http://decibel.fi.muni.cz/~xslaby/config-memrlimit-oops
I don't play with cgroups or anything, I just work on the system. Do you need a
test case, it's obvious from the code as far as I can see?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
