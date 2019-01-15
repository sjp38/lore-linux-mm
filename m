Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7FC418E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 20:40:15 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id d3so670228pgv.23
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 17:40:15 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r196si1740407pgr.311.2019.01.14.17.40.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 17:40:14 -0800 (PST)
Subject: Re: [PATCH v4 2/2] selftests/memfd: Add tests for F_SEAL_FUTURE_WRITE
 seal
References: <20190112203816.85534-1-joel@joelfernandes.org>
 <20190112203816.85534-3-joel@joelfernandes.org>
From: shuah <shuah@kernel.org>
Message-ID: <f9ffb7f8-1ff8-3bec-ce79-f9322d8715dc@kernel.org>
Date: Mon, 14 Jan 2019 18:39:59 -0700
MIME-Version: 1.0
In-Reply-To: <20190112203816.85534-3-joel@joelfernandes.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>, linux-kernel@vger.kernel.org
Cc: dancol@google.com, minchan@kernel.org, Jann Horn <jannh@google.com>, John Stultz <john.stultz@linaro.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Hugh Dickins <hughd@google.com>, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-mm@kvack.org, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, shuah <shuah@kernel.org>

On 1/12/19 1:38 PM, Joel Fernandes wrote:
> From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
> 
> Add tests to verify sealing memfds with the F_SEAL_FUTURE_WRITE works as
> expected.
> 
> Cc: dancol@google.com
> Cc: minchan@kernel.org
> Cc: Jann Horn <jannh@google.com>
> Cc: John Stultz <john.stultz@linaro.org>
> Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
> ---

Looks good to me. For selftest part of the series:

Reviewed-by: Shuah Khan <shuah@kernel.org>

thanks,
-- Shuah
