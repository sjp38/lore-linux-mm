Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 2FB1B6B0044
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 17:11:33 -0400 (EDT)
Message-ID: <508705BE.2020403@am.sony.com>
Date: Tue, 23 Oct 2012 14:01:50 -0700
From: Tim Bird <tim.bird@am.sony.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm/slob: Mark zone page state to get slab usage at
 /proc/meminfo
References: <1350907434-2202-1-git-send-email-elezegarcia@gmail.com> <0000013a88ebfa65-af0fc24b-13fd-400f-b7fc-32230ca70620-000000@email.amazonses.com> <CALF0-+VqGrcjw16rNPH459YAj7dubQnruzV-zOzYn6feOtQ4tQ@mail.gmail.com> <0000013a8ed646c2-4cc34bd5-19c3-4e99-9fa0-248cdbc24feb-000000@email.amazonses.com> <CALF0-+WASdSAT9rnLxx8OmHrNV5tjrDwpBTE9irCRd91QxMkBA@mail.gmail.com> <0000013a8f524097-4ebaed3b-0d77-4183-a6ad-f01b8855f9bf-000000@email.amazonses.com>
In-Reply-To: <0000013a8f524097-4ebaed3b-0d77-4183-a6ad-f01b8855f9bf-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On 10/23/2012 1:31 PM, Christoph Lameter wrote:
> On Tue, 23 Oct 2012, Ezequiel Garcia wrote:
>
>> The issue is: with SLUB large kmallocs don't set NR_SLAB_UNRECLAIMABLE
>> zone item.
>> Thus, they don't show at /proc/meminfo. Is this okey?
> Yes. Other large allocations that are done directly via __get_free_pages()
> etc also do not show up there. Slab allocators are intended for small
> allocation and are not effective for large scale allocs. People will
> use multiple different ways of acquiring large memory areas. So there is
> no consistent accounting for that memory.
>
>
>
There's a certain irony here.  In embedded, we get all worked
up about efficiencies in the slab allocators, but don't have a good
way to track the larger memory allocations.  Am I missing
something, or is there really no way to track these large
scale allocations?
  -- Tim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
