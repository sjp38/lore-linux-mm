Received: by rv-out-0708.google.com with SMTP id f25so4278784rvb.26
        for <linux-mm@kvack.org>; Fri, 11 Jul 2008 01:25:31 -0700 (PDT)
Message-ID: <84144f020807110125t667e2d2fi3b111c1127da3062@mail.gmail.com>
Date: Fri, 11 Jul 2008 11:25:31 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [RFC PATCH 0/5] kmemtrace RFC patch series
In-Reply-To: <20080710210543.1945415d@linux360.ro>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080710210543.1945415d@linux360.ro>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Eduard-Gabriel,

On Thu, Jul 10, 2008 at 9:05 PM, Eduard - Gabriel Munteanu
<eduard.munteanu@linux360.ro> wrote:
> I'd like to hear your opinion regarding kmemtrace and SL*B hooks.
>
> This is just a RFC, it's not intended to be merged yet. The userspace
> app is not included.

It would probably be helpful for anyone reviewing these patches to see
what the userspace program is doing. Can you please post an URL to a
tarball of the thing or its git repository?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
