Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 7D3946B002B
	for <linux-mm@kvack.org>; Tue, 25 Dec 2012 07:05:05 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id oi10so7203915obb.26
        for <linux-mm@kvack.org>; Tue, 25 Dec 2012 04:05:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <535932623.34838584.1356410331076.JavaMail.root@redhat.com>
References: <1621091901.34838094.1356409676820.JavaMail.root@redhat.com>
	<535932623.34838584.1356410331076.JavaMail.root@redhat.com>
Date: Tue, 25 Dec 2012 20:05:04 +0800
Message-ID: <CAJd=RBB9Tqv9c_Wv+N8yJOftfkJeUS10vLuz14eoLH1eEtjmBQ@mail.gmail.com>
Subject: Re: kernel BUG at mm/huge_memory.c:1798!
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouping Liu <zliu@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Johannes Weiner <jweiner@redhat.com>, mgorman@suse.de, hughd@google.com, Andrea Arcangeli <aarcange@redhat.com>

On Tue, Dec 25, 2012 at 12:38 PM, Zhouping Liu <zliu@redhat.com> wrote:
> Hello all,
>
> I found the below kernel bug using latest mainline(637704cbc95),
> my hardware has 2 numa nodes, and it's easy to reproduce the issue
> using LTP test case: "# ./mmap10 -a -s -c 200":

Can you test with 5a505085f0 and 4fc3f1d66b1 reverted?

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
