Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5566B0261
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 20:49:49 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id b202so177685012oii.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 17:49:49 -0800 (PST)
Received: from mail-oi0-x22e.google.com (mail-oi0-x22e.google.com. [2607:f8b0:4003:c06::22e])
        by mx.google.com with ESMTPS id y50si5362880otb.334.2016.12.16.17.49.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 17:49:48 -0800 (PST)
Received: by mail-oi0-x22e.google.com with SMTP id y198so95921226oia.1
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 17:49:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jqN+GkO7pL0QE0vM50MmqPZ1aD2G3YmziKvp+4+oh5gQ@mail.gmail.com>
References: <20161212164708.23244-1-jack@suse.cz> <20161213115209.GG15362@quack2.suse.cz>
 <CAPcyv4giLyY8pWP09V5BmUM+sfGO-VJCtkfV6L-RFS+0XQsT9Q@mail.gmail.com> <CAPcyv4jqN+GkO7pL0QE0vM50MmqPZ1aD2G3YmziKvp+4+oh5gQ@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 16 Dec 2016 17:49:47 -0800
Message-ID: <CAPcyv4iA78SAaNQC82NTziJFWX0mzq2wq6bFrXcn_3iiESOEzw@mail.gmail.com>
Subject: Re: [PATCH 0/6 v3] dax: Page invalidation fixes
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux MM <linux-mm@kvack.org>, linux-ext4 <linux-ext4@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Fri, Dec 16, 2016 at 5:35 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> On Tue, Dec 13, 2016 at 10:57 AM, Dan Williams <dan.j.williams@intel.com> wrote:
>> On Tue, Dec 13, 2016 at 3:52 AM, Jan Kara <jack@suse.cz> wrote:
>>> On Mon 12-12-16 17:47:02, Jan Kara wrote:
>>>> Hello,
>>>>
>>>> this is the third revision of my fixes of races when invalidating hole pages in
>>>> DAX mappings. See changelogs for details. The series is based on my patches to
>>>> write-protect DAX PTEs which are currently carried in mm tree. This is a hard
>>>> dependency because we really need to closely track dirtiness (and cleanness!)
>>>> of radix tree entries in DAX mappings in order to avoid discarding valid dirty
>>>> bits leading to missed cache flushes on fsync(2).
>>>>
>>>> The tests have passed xfstests for xfs and ext4 in DAX and non-DAX mode.
>>>>
>>>> Johannes, are you OK with patch 2/6 in its current form? I'd like to push these
>>>> patches to some tree once DAX write-protection patches are merged.  I'm hoping
>>>> to get at least first three patches merged for 4.10-rc2... Thanks!
>>>
>>> OK, with the final ack from Johannes and since this is mostly DAX stuff,
>>> can we take this through NVDIMM tree and push to Linus either late in the
>>> merge window or for -rc2? These patches require my DAX patches sitting in mm
>>> tree so they can be included in any git tree only once those patches land
>>> in Linus' tree (which may happen only once Dave and Ted push out their
>>> stuff - this is the most convoluted merge window I'd ever to deal with ;-)...
>>> Dan?
>>>
>>
>> I like the -rc2 plan better than sending a pull request based on some
>> random point in the middle of the merge window. I can give Linus a
>> heads up in my initial nvdimm pull request for -rc1 that for
>> coordination purposes we'll be sending this set of follow-on DAX
>> cleanups for -rc2.
>
> So what's still pending for -rc2? I want to be explicit about what I'm
> requesting Linus be prepared to receive after -rc1. The libnvdimm pull
> request is very light this time around since I ended up deferring the
> device-dax-subdivision topic until 4.11 and sub-section memory hotplug
> didn't make the cutoff for -mm. We can spend some of that goodwill on
> your patches ;-).
>
> I can roll them into libnvdimm-for-next now for the integration
> testing coverage, rebase to -rc1 when it's out, wait for your thumbs
> up on the testing and send a pull request on the 23rd.

Sorry, I meant the 30th of December.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
