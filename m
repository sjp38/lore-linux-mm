Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [PATCH]Fix: Init page count for all pages during higher order allocs
Date: Thu, 2 May 2002 23:13:34 +0200
References: <Pine.LNX.4.21.0205021312370.999-100000@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.21.0205021312370.999-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E173NtU-0002Ak-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, Suparna Bhattacharya <suparna@in.ibm.com>
Cc: Andrew Morton <akpm@zip.com.au>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, marcelo@brutus.conectiva.com.br, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 02 May 2002 15:08, Hugh Dickins wrote:
> On Thu, 2 May 2002, Suparna Bhattacharya wrote:
> As someone else noted in this thread, the kernel tries to keep
> pages in use anyway, so omitting free pages won't buy you a great
> deal on its own.  And I think it's to omit free pages that you want
> to distinguish the count 0 continuations from the count 0 frees?

Then why not count=-1 for the continuation pages?

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
