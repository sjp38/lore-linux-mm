Received: by wr-out-0506.google.com with SMTP id 70so1589275wra.26
        for <linux-mm@kvack.org>; Sun, 02 Mar 2008 09:01:43 -0800 (PST)
Message-ID: <2f11576a0803020901n715fda8esbfc0172f5a15ae3c@mail.gmail.com>
Date: Mon, 3 Mar 2008 02:01:40 +0900
From: "KOSAKI Motohiro" <m-kosaki@ceres.dti.ne.jp>
Subject: Re: [PATCH 2.6.24] mm: BadRAM support for broken memory
In-Reply-To: <20080302134221.GA25196@phantom.vanrein.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080302134221.GA25196@phantom.vanrein.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rick van Rein <rick@vanrein.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi

in general,
Agreed with we need bad memory treatness.

>  +#define PG_badram              20      /* BadRam page */

some architecture use PG_reserved for treat bad memory.
Why do you want introduce new page flag?
for show_mem() improvement?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
