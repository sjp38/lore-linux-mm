Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id ACB106B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 21:51:32 -0400 (EDT)
Received: by obcxo2 with SMTP id xo2so44486418obc.0
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 18:51:32 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id f18si6317060oem.54.2015.03.18.18.51.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 18:51:31 -0700 (PDT)
Message-ID: <550A2B9A.3060905@oracle.com>
Date: Wed, 18 Mar 2015 18:51:22 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 4/4] hugetlbfs: document min_size mount option
References: <cover.1426549010.git.mike.kravetz@oracle.com>	<3c82f2203e5453ddf3b29431863034afc7699303.1426549011.git.mike.kravetz@oracle.com> <20150318144108.e235862e0be30ff626e01820@linux-foundation.org>
In-Reply-To: <20150318144108.e235862e0be30ff626e01820@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 03/18/2015 02:41 PM, Andrew Morton wrote:
> On Mon, 16 Mar 2015 16:53:29 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:
>
>> Update documentation for the hugetlbfs min_size mount option.
>>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>> ---
>>   Documentation/vm/hugetlbpage.txt | 21 ++++++++++++++-------
>>   1 file changed, 14 insertions(+), 7 deletions(-)
>>
>> diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
>> index f2d3a10..83c0305 100644
>> --- a/Documentation/vm/hugetlbpage.txt
>> +++ b/Documentation/vm/hugetlbpage.txt
>> @@ -267,8 +267,8 @@ call, then it is required that system administrator mount a file system of
>>   type hugetlbfs:
>>
>>     mount -t hugetlbfs \
>> -	-o uid=<value>,gid=<value>,mode=<value>,size=<value>,nr_inodes=<value> \
>> -	none /mnt/huge
>> +	-o uid=<value>,gid=<value>,mode=<value>,size=<value>,min_size=<value>, \
>> +	nr_inodes=<value> none /mnt/huge
>>
>>   This command mounts a (pseudo) filesystem of type hugetlbfs on the directory
>>   /mnt/huge.  Any files created on /mnt/huge uses huge pages.  The uid and gid
>> @@ -277,11 +277,18 @@ the uid and gid of the current process are taken.  The mode option sets the
>>   mode of root of file system to value & 01777.  This value is given in octal.
>>   By default the value 0755 is picked. The size option sets the maximum value of
>>   memory (huge pages) allowed for that filesystem (/mnt/huge). The size is
>> -rounded down to HPAGE_SIZE.  The option nr_inodes sets the maximum number of
>> -inodes that /mnt/huge can use.  If the size or nr_inodes option is not
>> -provided on command line then no limits are set.  For size and nr_inodes
>> -options, you can use [G|g]/[M|m]/[K|k] to represent giga/mega/kilo. For
>> -example, size=2K has the same meaning as size=2048.
>> +rounded down to HPAGE_SIZE.  The min_size option sets the minimum value of
>> +memory (huge pages) allowed for the filesystem.  Like the size option,
>> +min_size is rounded down to HPAGE_SIZE.  At mount time, the number of huge
>> +pages specified by min_size are reserved for use by the filesystem.  If
>> +there are not enough free huge pages available, the mount will fail.  As
>> +huge pages are allocated to the filesystem and freed, the reserve count
>> +is adjusted so that the sum of allocated and reserved huge pages is always
>> +at least min_size.  The option nr_inodes sets the maximum number of
>> +inodes that /mnt/huge can use.  If the size, min_size or nr_inodes option
>> +is not provided on command line then no limits are set.  For size, min_size
>> +and nr_inodes options, you can use [G|g]/[M|m]/[K|k] to represent
>> +giga/mega/kilo. For example, size=2K has the same meaning as size=2048.
>
> Nowhere here is the reader told the units of "size".  We should at
> least describe that, and maybe even rename the thing to min_bytes.
>

Ok, I will add that the size is in unit of bytes.  My choice of
'min_size' as a name for the new mount option was influenced by
the existing 'size' mount option.  I'm open to any suggestions
for the name of this new mount option.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
