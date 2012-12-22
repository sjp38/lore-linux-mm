Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 2F9296B0078
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 23:21:54 -0500 (EST)
Message-ID: <50D53639.6040604@redhat.com>
Date: Fri, 21 Dec 2012 23:25:29 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/9] mm: make mlockall preserve flags other than VM_LOCKED
 in def_flags
References: <1356050997-2688-1-git-send-email-walken@google.com> <1356050997-2688-2-git-send-email-walken@google.com>
In-Reply-To: <1356050997-2688-2-git-send-email-walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/20/2012 07:49 PM, Michel Lespinasse wrote:
> On most architectures, def_flags is either 0 or VM_LOCKED depending on
> whether mlockall(MCL_FUTURE) was called. However, this is not an absolute
> rule as kvm support on s390 may set the VM_NOHUGEPAGE flag in def_flags.
> We don't want mlockall to clear that.
>
> Signed-off-by: Michel Lespinasse <walken@google.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
