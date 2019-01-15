Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD2C18E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 09:50:08 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id u20so2568317qtk.6
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 06:50:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g65sor22938035qkd.1.2019.01.15.06.50.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 06:50:08 -0800 (PST)
Date: Tue, 15 Jan 2019 09:50:05 -0500
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH v4 2/2] selftests/memfd: Add tests for
 F_SEAL_FUTURE_WRITE seal
Message-ID: <20190115145005.GC36681@google.com>
References: <20190112203816.85534-1-joel@joelfernandes.org>
 <20190112203816.85534-3-joel@joelfernandes.org>
 <f9ffb7f8-1ff8-3bec-ce79-f9322d8715dc@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f9ffb7f8-1ff8-3bec-ce79-f9322d8715dc@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuah <shuah@kernel.org>
Cc: linux-kernel@vger.kernel.org, dancol@google.com, minchan@kernel.org, Jann Horn <jannh@google.com>, John Stultz <john.stultz@linaro.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Hugh Dickins <hughd@google.com>, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-mm@kvack.org, =?iso-8859-1?Q?Marc-Andr=E9?= Lureau <marcandre.lureau@redhat.com>, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

On Mon, Jan 14, 2019 at 06:39:59PM -0700, shuah wrote:
> On 1/12/19 1:38 PM, Joel Fernandes wrote:
> > From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
> > 
> > Add tests to verify sealing memfds with the F_SEAL_FUTURE_WRITE works as
> > expected.
> > 
> > Cc: dancol@google.com
> > Cc: minchan@kernel.org
> > Cc: Jann Horn <jannh@google.com>
> > Cc: John Stultz <john.stultz@linaro.org>
> > Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
> > ---
> 
> Looks good to me. For selftest part of the series:
> 
> Reviewed-by: Shuah Khan <shuah@kernel.org>

Thanks!

John, could you provide your Reviewed-by again for patch 1/2 ? I had dropped
it since the patch had some more changes.

thanks,

 - Joel
