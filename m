Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 56AD26B011F
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 16:42:30 -0400 (EDT)
Received: by mail-ea0-f178.google.com with SMTP id o10so1535058eaj.23
        for <linux-mm@kvack.org>; Fri, 05 Apr 2013 13:42:28 -0700 (PDT)
Message-ID: <515F3701.1080504@gmail.com>
Date: Fri, 05 Apr 2013 22:41:37 +0200
From: Ivan Danov <huhavel@gmail.com>
MIME-Version: 1.0
Subject: Re: System freezes when RAM is full (64-bit)
References: <5159DCA0.3080408@gmail.com> <20130403121220.GA14388@dhcp22.suse.cz> <515CC8E6.3000402@gmail.com> <20130404070856.GB29911@dhcp22.suse.cz> <515D89BE.2040609@gmail.com> <20130404151658.GJ29911@dhcp22.suse.cz> <515EA3B7.5030308@gmail.com> <20130405115914.GD31132@dhcp22.suse.cz>
In-Reply-To: <20130405115914.GD31132@dhcp22.suse.cz>
Content-Type: multipart/mixed;
 boundary="------------020900000504020104030103"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Simon Jeons <simon.jeons@gmail.com>, linux-mm@kvack.org, 1162073@bugs.launchpad.net

This is a multi-part message in MIME format.
--------------020900000504020104030103
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Here you can find attached the script, collecting the logs and the logs 
themselves during the described process of freezing. It appeared that 
the previous logs are corrupted, because both /proc/vmstat and 
/proc/meminfo have been logging to the same file.
--
On 05/04/13 13:59, Michal Hocko wrote:
> On Fri 05-04-13 12:13:11, Ivan Danov wrote:
>> Tried with vm.swappiness=60, but the only improvement is that now
>> the mouse input is less choppy than before, but still the problem
>> remains - the computer is not usable at all, one could not even stop
>> the program, causing the problem.
> OK, could you collect /proc/vmstat and /proc/meminfo during that load?
>
>> Best,
>> Ivan
>> --
>> On 04/04/13 17:16, Michal Hocko wrote:
>>> On Thu 04-04-13 16:10:06, Ivan Danov wrote:
>>>> Hi Michal,
>>>>
>>>> Yes, I use swap partition (2GB), but I have applied some things for
>>>> keeping the life of the SSD hard drive longer. All the things I have
>>>> done are under point 3. at
>>>> http://www.rileybrandt.com/2012/11/18/linux-ultrabook/.
>>> OK, I guess I know what's going on here.
>>> So you did set vm.swappiness=0 which (for some time) means that there is
>>> almost no swapping going on (although you have plenty of swap as you are
>>> mentioning above).
>>> This shouldn't be a big deal normally but you are also backing your
>>> /tmp on tmpfs which is in-memory filesystem. This means that if you
>>> are writing to /tmp a lot then this content will fill up your memory
>>> which is not swapped out until the memory reclaim is getting into real
>>> troubles - most of the page cache is dropped by that time so your system
>>> starts trashing.
>>>
>>> I would encourage you to set swappiness to a more reasonable value (I
>>> would use the default value which is 60). I understand that you are
>>> concerned about your SSD lifetime but your user experience sounds like a
>>> bigger priority ;)
>>>
>>>> By system freezes, I mean that the desktop environment doesn't react
>>>> on my input. Just sometimes the mouse is reacting very very choppy
>>>> and slowly, but most of the times it is not reacting at all. In the
>>>> attached file, I have the output of the script and the content of
>>>> dmesg for all levels from warn to emerg, as well as my kernel config.
>>> I haven't checked your attached data but you should get an overview from
>>> Shmem line from /proc/meminfo which tells you how much shmem/tmpfs
>>> memory you are using and grep "^Swap" /proc/meminfo will tell you more
>>> about your swap usage.
>>>
>>>> Best,
>>>> Ivan
>>> HTH


--------------020900000504020104030103
Content-Type: application/x-gzip;
 name="bug-with-swappiness.tar.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="bug-with-swappiness.tar.gz"

H4sIABg2X1EAA+xdbW8jOXLez/4VCpIAFwTIksUqvgRIgLsNDhckGxxudpOPOo2tGStjy44k
z+Du16fY7FaT3aTstmRZt0cecDsmW/1GNuupp94+Pn3+/rs3boKbMeT/Kw2J+L9d+06CBKMV
kD9OCgXquxm99Y359rTdLTaz2Xerr4v1oeOeG/8LbR95/r/e8zvY/ZNUmqRD4fSJr+EnWGss
zT9Kqfv519wvQRN8NxMnvo9s+yuf//Vm/mmzXM4fF5+X25nUVjpxxZ2r9eJ6t/q6nC/WD+uZ
Ap4v9P1xr1QETrnk8E+ru+UMlEyObjql49XlO5/Wy6+r693iI3caa5Tvu797uP6y/8ufvbsj
UoYXS3PM4vFxeTNDo8j4v/1Zu6OcslL6zpvVZvenmZTNL75tVrvlxwWfWUoH4Lu2d4uP883y
+m6xum/ugFc99iNP63SMhPZj/irz5o67CxoRfvVluVkv7+a8iPz9kw4PuA1P17zJjw9P6+v2
3/ylXS/W4b74phEw6l3d3y9vVovdsru/mcTkKea75f1jONFq+3DHR96EiUi7mrfddG1v75f3
M+esdt27WfEblNKEmfBn3i15Ig0fc7V+ul/Mb1e7mTGACC503K+2W382/+9PD5vl6vO6+3O1
3i03d8vFV55HPmXo5Ilc3KWneNjdLjfhjpqZ3W0W6+3jYrNc7+a3T5+X4ZWK/fTNd7eb5fb2
4c7fqkSSph/y7+Hzhl/pTXSUQSV4+h8/P35e8dMA8P6imj8fnnb8FnlDwavH7bdHPxr+1Qw0
E/D4eXHHNz2/uV/wPUR/KZiBccZZt+9dP2zu+enQ8bJHte++f/jazvfjZ/81zYzTkjc5f4D/
AhZ+tol3OuKem+W+TymLYPyPFk93u5n1z8oT8fj5fvG/oQud9CfdLHlS7/a32P/J9yg18Cba
97b3KPkW/LN23fE9bnfLxd38y/bb4vFmf9Jhpz81f2tyONSeH4DfsRoOjq/C07a83g2u0nfy
VbRUZjjSXoSMNqOx5Br+wxk+SNrHVyBU4Vajke4xLJGGwdjoCsOHSPv8QnFKucFIewWr/eeX
DvUX+PPDev+9zz8t+NO9aS6xWj/cLJvH5j/91rSd+xOs/ecrjHJw1d5rcmDbd/fwbf7tfrH5
4j/n+f89ra6/3P1pZrvh29Xn28z4/ufbL6vH+fXDmr/K3Yq/128L3hQkv0D+Tvm72TytZ0hA
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
fJ2xASi1+FQDUDUAVQNQNQCd3/9XivPmf/Gtx3+Gavz3GVsO/5+Y/nsB/o/mX7T1f+v8n6Wl
+N/bJKzI4H9AMSr/ZRn9G8jAf+WIRvF/BFJn4H8ovtXB//BXBP8tGh2yQLbo32gKRYQj9K+M
RhMV/9Uvc/9iJbOU+tM1oXE57C9tiI9MsL+GCwv+s0o6E2N/hv5J4n8jbOT8pawkxKMKfiWn
OAr7gyR6PvaP94w+9k8YUJb22B8bv8SJ2N/yGmocyFLoz+qnO1T2F0kDqcT3S/OLGBT66qE/
sqJiIAn9U9a4Cv0r9K/Q/wKhP3/Jv1To3zSP//zxvLjfDGN4kOc53hL+B9n7/ytinCil1tX+
e5b2t3/z/cfV+vvt7dW3Ww8ieKtYXt08XHmjzIeffv3j7//ljzdegv3j32//2HReL3az7x83
D9ed2jj711mnQP5d84vBYUG7mPFhrZ4RHbW9Wy4fZ7DlK66X1fLzDi2j/+GJ3T9foP/19R/Q
BP2v6v/naQP9z0ihXEb/I0NipP9RIx4z+h+JRFvs9D/KlH9+Tv/TBKGUW6f/YasPJvof4/2+
VtiMQuGwFyiAUhYVQFmo/SaNySmA7sIUQE2p8ccKmyiAPB4pgOB8lb2jjD/JKY5UAB08X/nN
uMZg0iqApGxk/EEfkzxVAUTpt6mhAgjEFyIqK4BKa19gOlUAQzHgrALIW5xUTe3oSAFsCkNX
BbAqgFUBrArgWRXAbPzPe+b/FdX/95xtWvyPEmRDVEI2/sdAIf6HlJZiev5/ZbUESOJ4Iv9f
6PINj+N/NPoUMIX4H+pyi+Tif1jcl+J/tFH6QP6X88b/+O9levyP1qZ9vlz+X6FL+f+9Q6or
5H+ZOSeK+f9JQzH/S1NTtxj/Y4r+v8TQ81Lif7zHE7za/zdJHTPy/23fTvX/re3tWjb//3vG
/8ga/3vONjH/v1VGF+N/FYaYm2z+f6deEf8jeRd0hfhfFh9WFuJ/Hfji7yX5z5I8xg1p/n8w
JflvbBtTdAnxP9AmD5uY/x99wvqS/NcH5L9ypfhfKcC12CCb/78c/4NtrYXp+f/hQuJ/rLIY
3tkbxP8aW+N/a3vjlo3/fc/8H6rW/zlnmxj/C12uh6n1/3hTe2X8b7H+D++uxfp/0ppBHb9e
/jtHSd2gWP5T9ww5+Y9tvtJLkP/KwvT6PyyrWMcvxf9q18q5XP5XBViO/9VYrv9H5fo/usUG
+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
+D+P+vVy5/835j9ZQz3t/4f/8yl1LP8xK2Oc/3Bj/tdaygPzf+Zc1vP4Yv5XktUcv8h/YrJZ
Nsp/YEKK8D8prvuN1fxP+Dn5j8LH53+y0bnncPnzf9/VO/t/+05oOP/3nZA7/zNE+G/zfwrx
X9L0Pr35v/T8znfjf6P8CDyT/7hcHeznfxz4P+qXy/N/Ol//T4v854n/OfIfz6k1/1NsclZH
/6UGjLClf1ahNHEuN+xPGyMn4dTK/gmVHfn/HfunKppX6n+1uZ825E+yR7TMdkHWGtQfkT+p
YEj+TDBxTvfkz8ZN2ZE/86dpvxS1rN2fkFfOrwUoL9yfWryl1Kfcn5Yv8RT1swn577s/ZUPX
b+onEBeelV9MFfkw9TO1KMuyo37aT4KU+S/v3Z8Mx0tdUT9zxrTxfZ2pn9w8Euqa+okXbumg
fg7q56B+fhr18x92fwryP18sADqW/znuP2fWsfuPwpWV5ud/lij/k7jfho7dfzBfszod/qfN
1uTnf4oBLIb3n0YqWfJGVvmfjOu88VX+Z7m1/zn3/sN993Vo/yM2ayUI9j+th6Yo/xNQNdj/
XPI/Ob7/9D/z7j8Y739y0jD/O9P0Pt+9/7HPvOb+MzHuP2P/8zeW5//z4vPPQf3v5P9DI//n
lNrpfynn/f6ncfzV1f+iehugAsCe/rfgI/pf1LQygGSa/nvt/4O6yP+p9NP4nxsG4DJFoXr6
30mautb/Xj+5T1kBtW3GrInuBpA5LZdAmpGW+l/irE/F/6xe4ln7n3p/CUQXl+9Z/1thaQDJ
6fgSKNL/Nk7RjSWQqCDJKvGzKBaN9b/Q9cLDAHIsgcYS6NOXQP+y/neb/ygv7jHu9n/EC/7v
uP+dWev+D7I1BMnp//DqubL+v0WFPf8XUeS9/6O0o8jh/o+SMC8D4GvbEm77PzSAXvo/4nQQ
/IkBDMcNYAlugDmrE/+eP64BtGZ+k/wOad0A6rVZu+Q/tt8/pqfyH5cv8Wz+I//AAZxxvgK2
/EdZGMCINCPHYw0gQrKn/ez0cvV/tPGC9UbkexapUxbl7P+oCTYZMAh8CW7sHpDtink4/FGb
H/4u7r3R2p7rBenyTrxusCZ5SdL7LzaEYcA7JL4k7Xx+W4gK+b2dYeHRG47ecFhD/o/K6f/p
ZP9HKmX2fzdAvPT/efj/nFLr/r/kyln2/b9yRd22/9bvUvW6/xa8sov/seYfj8c/lqwJedH8
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
--------------020900000504020104030103--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
