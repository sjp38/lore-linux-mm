From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14338.25466.233239.59715@dukat.scot.redhat.com>
Date: Mon, 11 Oct 1999 23:23:54 +0100 (BST)
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <199910111907.MAA15028@google.engr.sgi.com>
References: <38022640.3447ECA6@colorfullife.com>
	<199910111907.MAA15028@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Manfred Spraul <manfreds@colorfullife.com>, viro@math.psu.edu, sct@redhat.com, andrea@suse.de, linux-kernel@vger.rutgers.edu, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 11 Oct 1999 12:07:08 -0700 (PDT), kanoj@google.engr.sgi.com
(Kanoj Sarcar) said:

>> What about something like a rw-semaphore which protects the vma list:
>> vma-list modifiers [ie merge_segments(), insert_vm_struct() and
>> do_munmap()] grab it exclusive, swapper grabs it "shared, starve
>> exclusive".
>> All other vma-list readers are protected by mm->mmap_sem.


> I have tried to follow most of the logic and solutions proposed
> on this thread. 

It will deadlock.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
