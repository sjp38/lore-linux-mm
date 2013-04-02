Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 80DCE6B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 14:04:50 -0400 (EDT)
Date: Tue, 2 Apr 2013 20:02:19 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] x86: add phys addr validity check for /dev/mem mmap
Message-ID: <20130402180219.GA26833@redhat.com>
References: <1364905733-23937-1-git-send-email-fhrbata@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1364905733-23937-1-git-send-email-fhrbata@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frantisek Hrbata <fhrbata@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, kamaleshb@in.ibm.com, hechjie@cn.ibm.com

On 04/02, Frantisek Hrbata wrote:
>
> Meaning there is a possibility to use mmap
> on /dev/mem and cause system panic. It's probably not that serious, because
> access to /dev/mem is limited and the system has to have panic_on_oops set, but
> still I think we should check this and return error.

Personally I agree. Even if panic_on_oops == F, do_page_fault(PF_RSVD) leading
to pgtable_bad() doesn't look good.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
