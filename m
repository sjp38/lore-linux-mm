Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 3070D6B0032
	for <linux-mm@kvack.org>; Sun, 30 Jun 2013 14:33:31 -0400 (EDT)
Date: Sun, 30 Jun 2013 20:28:37 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: mmotm 2013-06-27-16-36 uploaded (wait event common)
Message-ID: <20130630182837.GA5738@redhat.com>
References: <20130627233733.BAEB131C3BE@corp2gmr1-1.hot.corp.google.com> <51CD1F81.4040202@infradead.org> <65029.1372514416@turing-police.cc.vt.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <65029.1372514416@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On 06/29, Valdis.Kletnieks@vt.edu wrote:
>
> On Thu, 27 Jun 2013 22:30:41 -0700, Randy Dunlap said:
>
> > +		__ret = __wait_no_timeout(tout) ?: (tout) ?: 1;
>
> Was this trying to do a  wait_ho_timeout(!!tout)  or something?

No, __wait_no_timeout() means that tout == MAX_SCHEDULE_TIMEOUT.
But the logic is wrong, we should return zero in this case.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
