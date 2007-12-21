Message-ID: <476B1677.4020009@hp.com>
Date: Thu, 20 Dec 2007 20:27:19 -0500
From: Mark Seger <Mark.Seger@hp.com>
MIME-Version: 1.0
Subject: Re: SLUB
References: <476A850A.1080807@hp.com> <Pine.LNX.4.64.0712201138280.30648@schroedinger.engr.sgi.com> <476AFC6C.3080903@hp.com> <476B122E.7010108@hp.com>
In-Reply-To: <476B122E.7010108@hp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mark Seger <Mark.Seger@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I just realized I forgot to include an example of the output I was 
generating so here it is:

Slab Name              ObjSize   NumObj  SlabSize  NumSlab     Total
:0000008                     8     2185         8        5     17480
:0000016                    16     1604        16        9     25664
:0000024                    24      409        24        4      9816
:0000032                    32      380        32        5     12160
:0000040                    40      204        40        2      8160
:0000048                    48        0        48        0         0
:0000064                    64      843        64       17     53952
:0000072                    72      167        72        3     12024
:0000088                    88     5549        88      121    488312
:0000096                    96     1400        96       40    134400
:0000112                   112        0       112        0         0
:0000128                   128      385       128       21     49280
:0000136                   136       70       136        4      9520
:0000152                   152       59       152        4      8968
:0000160                   160       46       160        4      7360
:0000176                   176     2071       176       93    364496
:0000192                   192      400       192       24     76800
:0000256                   256     1333       256      100    341248
:0000288                   288       54       288        6     15552
:0000320                   320       53       320        7     16960
:0000384                   384       29       384        5     11136
:0000448                   420       22       448        4      9856
:0000512                   512      150       512       22     76800
:0000704                   696       33       704        3     23232
:0000768                   768       82       768       21     62976
:0000832                   776       98       832       15     81536
:0000896                   896       48       896       14     43008
:0000960                   944       39       960       15     37440
:0001024                  1024      303      1024       80    310272
:0001088                  1048       28      1088        4     30464
:0001608                  1608       34      1608        7     54672
:0001728                  1712       16      1728        5     27648
:0001856                  1856        8      1856        2     14848
:0001904                  1904       87      1904       28    165648
:0002048                  2048      504      2048      131   1032192
:0004096                  4096       49      4096       28    200704
:0008192                  8192        8      8192       12     65536
:0016384                 16384        4     16384        7     65536
:0032768                 32768        3     32768        3     98304
:0065536                 65536        1     65536        1     65536
:0131072                131072        0    131072        0         0
:0262144                262144        0    262144        0         0
:0524288                524288        0    524288        0         0
:1048576               1048576        0   1048576        0         0
:2097152               2097152        0   2097152        0         0
:4194304               4194304        0   4194304        0         0
:a-0000088                  88        0        88        0         0
:a-0000104                 104    13963       104      359   1452152
:a-0000168                 168        0       168        0         0
:a-0000224                 224    11113       224      619   2489312
:a-0000256                 248        0       256        0         0
anon_vma                    40      796        48       12     38208
bdev_cache                 960       32      1024        8     32768
ext2_inode_cache           920        0       928        0         0
ext3_inode_cache           968     4775       976     1194   4660400
file_lock_cache            192       58       200        4     11600
hugetlbfs_inode_cache       752        5       760        1      3800
idr_layer_cache            528       91       536       14     48776
inode_cache                720     3015       728      604   2194920
isofs_inode_cache          768        0       776        0         0
kmem_cache_node             72      232        72        6     16704
mqueue_inode_cache        1040        7      1088        1      7616
nfs_inode_cache           1120      102      1128       15    115056
proc_inode_cache           752      503       760      102    382280
radix_tree_node            552     2666       560      381   1492960
rpc_inode_cache            928       16       960        4     15360
shmem_inode_cache          960      243       968       61    235224
sighand_cache             2120       86      2176       31    187136
sock_inode_cache           816       81       832       11     67392
TOTAL K: 17169

and here's /proc/meminfo
MemTotal:      4040768 kB
MemFree:       3726112 kB
Buffers:         13864 kB
Cached:         196920 kB
SwapCached:          0 kB
Active:         127264 kB
Inactive:       127864 kB
SwapTotal:     4466060 kB
SwapFree:      4466060 kB
Dirty:              60 kB
Writeback:           0 kB
AnonPages:       44364 kB
Mapped:          16124 kB
Slab:            18608 kB
SReclaimable:    11768 kB
SUnreclaim:       6840 kB
PageTables:       2240 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:   6486444 kB
Committed_AS:    64064 kB
VmallocTotal: 34359738367 kB
VmallocUsed:     32364 kB
VmallocChunk: 34359705775 kB
HugePages_Total:     0
HugePages_Free:      0
HugePages_Rsvd:      0
Hugepagesize:     2048 kB

-mark

Mark Seger wrote:
> I did some preliminary prototyping and I guess I'm not sure of the 
> math.  If I understand what you're saying, an object has a particular 
> size, but given the fact that you may need alignment, the true size is 
> really the slab size, and the difference is the overhead.  What I 
> don't understand is how to calculate how much memory a particular slab 
> takes up.  If the slabsize is really the size of an object, wouldn't I 
> multiple that times the number of objects?  But when I do that I get a 
> number smaller than that reported in /proc/meminfo, in my case 15997K 
> vs 17388K.  Given memory numbers rarely seem to add up maybe this IS 
> close enough?  If so, what's the significance of the number of slabs?  
> Would I divide the 15997K by the number of slabs to find out how big a 
> single slab is?  I would have thought that's what the slab_size is but 
> clearly it isn't.
>
> In any event, here's a table of what I see on my machine.  The first 4 
> columns come from /sys/slab and the 5th I calculated by just 
> multiplying SlabSize X NumObj.  If I should be doing something else, 
> please tell me.  Also be sure to tell me if I should include other 
> data.  For example, the number of objects is a little misleading since 
> when I look at the file I really see something like:
>
> 49 N0=19 N1=30
>
> which I'm guessing may mean 19 objects are allocated to socket 0 and 
> 30 to socket 1?  this is a dual-core, dual-socket system.
>
> -mark
>
> Mark Seger wrote:
>>
>>>> Perhaps someone would like to take this discussion off-line with me 
>>>> and even
>>>> collaborate with me on enhancements for slub in collectl?
>> sounds good to me, I just didn't want to annoy anyone...
>>>> I think we better keep it public (so that it goes into the 
>>>> archive). Here a short description of the field in 
>>>> /sys/kernel/slab/<slabcache> that you would need
>>>>
>>>> -r--r--r-- 1 root root 4096 Dec 20 11:41 object_size
>>>>
>>>> The size of an object. Subtract slab_size - object_size and you 
>>>> have the per object overhead generated by alignements and slab 
>>>> metadata. Does not change you only need to read this once.
>>>>
>>>> -r--r--r-- 1 root root 4096 Dec 20 11:41 objects
>>>>
>>>> Number of objects in use. This changes and you may want to monitor it.
>>>>
>>>> -r--r--r-- 1 root root 4096 Dec 20 11:41 slab_size
>>>>
>>>> Total memory used for a single object. Read this only once.
>>>>
>>>> -r--r--r-- 1 root root 4096 Dec 20 11:41 slabs
>>>>
>>>> Number of slab pages in use for this slab cache. May change if slab 
>>>> is extended.
>>>>     
>> What I'm not sure about is how this maps to the old slab info.  
>> Specifically, I believe in the old model one reported on the size 
>> taken up by the slabs (number of slabs X number of objects/slab X 
>> object size).  There was a second size for the actual number of 
>> objects in use, so in my report that looked like this:
>>
>> #                      <-----------Objects----------><---------Slab 
>> Allocation------>
>> #Name                  InUse   Bytes   Alloc   Bytes   InUse   
>> Bytes   Total   Bytes
>> nfs_direct_cache           0       0       0       0       0       
>> 0       0       0
>> nfs_write_data            36   27648      40   30720       8   
>> 32768       8   32768
>>
>> the slab allocation was real memory allocated (which should come 
>> close to Slab: in /proc/meminfo, right?) for the slabs while the 
>> object bytes were those in use.  Is it worth it to continue this 
>> model or do thing work differently.   It sounds like I can still do 
>> this with the numbers you've pointed me to above and I do now realize 
>> I only need to monitor the number of slabs and the number of objects 
>> since the others are constants.
>>
>> To get back to my original question, I'd like to make sure that I'm 
>> reporting useful information and not just data for the sake of it.  
>> In one of your postings I saw a report you had that showed:
>>
>> slubinfo - version: 1.0
>> # name            <objects> <order> <objsize> <slabs>/<partial>/<cpu> 
>> <flags> <nodes>
>>
>> How useful is order, cpu, flags and nodes?
>> Do people really care about how much memory is taken up by objects vs 
>> slabs?  If not, I could see reporting for each slab:
>> - object size
>> - number objects
>> - slab size
>> - number of slabs
>> - total memory (slab size X number of slabs)
>> - whatever else people might think to be useful such as order, cpu, 
>> flags, etc
>>
>> Another thing I noticed is a number of the slabs are simply links to 
>> the same base name and is it sufficient to just report the base names 
>> and not those linked to it?  Seems reasonable to me...
>>
>> The interesting thing about collectl is that it's written in perl 
>> (but I'm trying to be very careful to keep it efficient and it tends 
>> to use <0.1% cpu when run as a daemon) and the good news is it's 
>> pretty easy to get something implemented, depending on my free time.  
>> If we can get some level of agreement on what seems useful I could 
>> get a version up fairly quickly for people to start playing with if 
>> there is any interest.
>>
>> -mark
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
