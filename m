Subject: Re: [PATCH] Reclaim orphaned swap pages
Message-ID: <OF739CF0A7.009BB731-ON85256A20.007C3A34@pok.ibm.com>
From: "Bulent Abali" <abali@us.ibm.com>
Date: Sat, 31 Mar 2001 17:46:41 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Tweedie <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>On Wed, 28 Mar 2001, Stephen Tweedie wrote:
>
>> Rik, the patch below tries to reclaim orphaned swap pages after
>> swapped processes exit.  I've only given it basic testing but I want
>> to get feedback on it sooner rather than later --- we need to do
>> _something_ about this problem!
>>
>> The patch works completely differently to the release-on-exit diffs:
>
>It looks good and simple enough to just plug into the
>kernel. I cannot see any problem with this patch, except
>that the PAGECACHE_LOCK macro doesn't seem to exist (yet)
>in my kernel tree ;))

Stephen,

I would like to test your patch.  Is there a resolution for the
non-existent
PAGECACHE_LOCK macro?

I believe I am running in to the orphaned swap pages problem in 2.4.3.
Killing a 900 MB process which is in the midst of being swapped out
leaves a huge chunk in the page cache and the swap file
long after process has exited.  Thanks in advance for any suggestions.

Bulent Abali


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
