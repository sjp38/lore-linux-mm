Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6E76B6B0010
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 15:53:54 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id e3-v6so12125468pld.13
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 12:53:54 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d31-v6si4997557pld.301.2018.10.05.12.53.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Oct 2018 12:53:53 -0700 (PDT)
Date: Fri, 5 Oct 2018 12:53:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RFC] mm: Add an fs-write seal to memfd
Message-Id: <20181005125339.f6febfd3fcfdc69c6f408c50@linux-foundation.org>
In-Reply-To: <20181005192727.167933-1-joel@joelfernandes.org>
References: <20181005192727.167933-1-joel@joelfernandes.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, kernel-team@android.com, jreck@google.com, john.stultz@linaro.org, tkjos@google.com, gregkh@linuxfoundation.org, Al Viro <viro@zeniv.linux.org.uk>, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>

On Fri,  5 Oct 2018 12:27:27 -0700 "Joel Fernandes (Google)" <joel@joelfernandes.org> wrote:

> To support the usecase, this patch adds a new F_SEAL_FS_WRITE seal which
> prevents any future mmap and write syscalls from succeeding while
> keeping the existing mmap active. The following program shows the seal
> working in action:

Please be prepared to create a manpage patch for this one.
