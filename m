Message-ID: <457D6944.4010703@yahoo.com.au>
Date: Tue, 12 Dec 2006 01:20:52 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Status of buffered write path (deadlock fixes)
References: <45751712.80301@yahoo.com.au> <20061207195518.GG4497@ca-server1.us.oracle.com> <4578DBCA.30604@yahoo.com.au> <20061208234852.GI4497@ca-server1.us.oracle.com> <457D20AE.6040107@yahoo.com.au>
In-Reply-To: <457D20AE.6040107@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Fasheh <mark.fasheh@oracle.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Andrew Morton <akpm@google.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Mark Fasheh wrote:

>> If we make the change I described above (looking for BH_New buffers 
>> outside
>> the range passed), then zero length or partial shouldn't matter, but zero
>> length instead of partial would be nicer imho just for the sake of 
>> reducing
>> the total number of cases down to the entire range or zero length.
> 
> 
> We don't want to do zero length, because we might make the theoretical
> livelock much easier to hit (eg. in the case of many small iovecs). But
> yes we can restrict ourselves to zero-length or full-length.

On second thoughts, I think I'm wrong about that.

Consider the last page of a file, which is uptodate. A full length
commit, which extends the file, will expose transient zeroes if the
usercopy fails.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
