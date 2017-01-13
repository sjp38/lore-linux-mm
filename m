Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id E5D646B0038
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 11:56:51 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id a16so49404989qkc.6
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 08:56:51 -0800 (PST)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id i53si6562014qtf.137.2017.01.13.08.56.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 08:56:50 -0800 (PST)
Received: by mail-qk0-x244.google.com with SMTP id a20so7918535qkc.3
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 08:56:50 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] mm patches review bandwidth
References: <20170105153737.GV21618@dhcp22.suse.cz>
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Message-ID: <10ede2fc-f073-996d-b4c5-b9712bb75b1e@gmail.com>
Date: Fri, 13 Jan 2017 11:56:42 -0500
MIME-Version: 1.0
In-Reply-To: <20170105153737.GV21618@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org



On 01/05/2017 10:37 AM, Michal Hocko wrote:
> Hi,
> I have a very bad feeling that we are running out of the patch review
> bandwidth for quite some time. Quite often it is really hard to get
> any feedback at all. This leaves Andrew in an unfortunate position when
> he is pushed to merge changes which are not reviewed.
>
> A quick check shows that around 40% of patches is not tagged with
> neither Acked-by nor Reviewed-by. While this is not any hard number it
> should give us at least some idea...
>
> $ git rev-list --no-merges v4.8..v4.9 -- mm/ | wc -l
> 150
> $ git rev-list --no-merges v4.8..v4.9 -- mm/ | while read sha1; do git show $sha1 | grep "Acked-by\|Reviewed-by" >/dev/null&& echo $sha1; done | wc -l
> 87
>
> The overall trend since 4.0 shows that this is quite a consistent number
>
> 123 commits in 4.0..4.1 range 47 % unreviewed
> 170 commits in 4.1..4.2 range 56 % unreviewed
> 187 commits in 4.2..4.3 range 35 % unreviewed
> 176 commits in 4.3..4.4 range 34 % unreviewed
> 220 commits in 4.4..4.5 range 32 % unreviewed
> 199 commits in 4.5..4.6 range 42 % unreviewed
> 217 commits in 4.6..4.7 range 41 % unreviewed
> 247 commits in 4.7..4.8 range 39 % unreviewed
> 150 commits in 4.8..4.9 range 42 % unreviewed
>
> I am worried that the number of patches posted to linux-mm grows over
> time while the number of reviewers doesn't scale up with that trend. I
> believe we need to do something about that and aim to increase both the
> number of reviewers as well as the number of patches which are really
> reviewed. I am not really sure how to achieve that, though. Requiring
> Acked-by resp. Reviewed-by on each patch sounds like the right approach
> but I am just worried that even useful changes could get stuck without
> any forward progress that way.


On 01/05/2017 10:37 AM, Michal Hocko wrote:
 > Hi,
 > I have a very bad feeling that we are running out of the patch review
 > bandwidth for quite some time. Quite often it is really hard to get
 > any feedback at all. This leaves Andrew in an unfortunate position when
 > he is pushed to merge changes which are not reviewed.
 >
 > A quick check shows that around 40% of patches is not tagged with
 > neither Acked-by nor Reviewed-by. While this is not any hard number it
 > should give us at least some idea...
 >
 > $ git rev-list --no-merges v4.8..v4.9 -- mm/ | wc -l
 > 150
 > $ git rev-list --no-merges v4.8..v4.9 -- mm/ | while read sha1; do git show $sha1 | grep "Acked-by\|Reviewed-by" >/dev/null&& echo $sha1; done | wc -l
 > 87
 >
 > The overall trend since 4.0 shows that this is quite a consistent number
 >
 > 123 commits in 4.0..4.1 range 47 % unreviewed
 > 170 commits in 4.1..4.2 range 56 % unreviewed
 > 187 commits in 4.2..4.3 range 35 % unreviewed
 > 176 commits in 4.3..4.4 range 34 % unreviewed
 > 220 commits in 4.4..4.5 range 32 % unreviewed
 > 199 commits in 4.5..4.6 range 42 % unreviewed
 > 217 commits in 4.6..4.7 range 41 % unreviewed
 > 247 commits in 4.7..4.8 range 39 % unreviewed
 > 150 commits in 4.8..4.9 range 42 % unreviewed
 >
 > I am worried that the number of patches posted to linux-mm grows over
 > time while the number of reviewers doesn't scale up with that trend. I
 > believe we need to do something about that and aim to increase both the
 > number of reviewers as well as the number of patches which are really
 > reviewed. I am not really sure how to achieve that, though. Requiring
 > Acked-by resp. Reviewed-by on each patch sounds like the right approach
 > but I am just worried that even useful changes could get stuck without
 > any forward progress that way.

Here are additional information.

Rate of unreviewed patch (Unreviewed patch/Total patch))
  Version     : mm           : arch/x86     : fs/ext4      : fs/xfs       : fs/btrfs     :
  v3.0..v3.1  : 56 ( 86/151) : 79 (277/349) : 90 ( 75/ 83) : 29 ( 28/ 96) : 96 (103/107) :
  v3.1..v3.2  : 45 ( 61/135) : 88 (227/256) : 95 (105/110) : 48 ( 42/ 86) : 98 (182/184) :
  v3.2..v3.3  : 42 ( 94/221) : 85 (281/329) : 97 ( 45/ 46) : 23 ( 12/ 51) : 96 (127/131) :
  v3.3..v3.4  : 42 ( 55/130) : 76 (259/339) : 84 ( 50/ 59) : 12 (  7/ 57) : 99 (117/118) :
  v3.4..v3.5  : 38 ( 70/182) : 81 (293/358) : 88 ( 38/ 43) : 18 ( 13/ 71) : 91 ( 99/108) :
  v3.5..v3.6  : 37 ( 65/173) : 76 (234/305) : 78 ( 32/ 41) : 16 (  9/ 53) : 96 (100/104) :
  v3.6..v3.7  : 54 (112/205) : 73 (296/404) : 81 ( 64/ 79) : 27 ( 11/ 40) : 98 (148/151) :
  v3.7..v3.8  : 51 (124/239) : 77 (175/225) : 70 ( 54/ 77) :  1 (  1/ 89) : 91 (147/161) :
  v3.8..v3.9  : 52 ( 91/173) : 65 (279/428) : 67 ( 64/ 95) :  2 (  1/ 44) : 93 (152/162) :
  v3.9..v3.10 : 51 ( 68/132) : 68 (204/300) : 78 ( 40/ 51) :  1 (  1/ 81) : 85 (114/134) :
v3.10..v3.11 : 51 ( 83/162) : 64 (128/200) : 61 ( 52/ 85) :  4 (  3/ 74) : 93 ( 93/100) :
v3.11..v3.12 : 40 ( 91/222) : 51 (109/211) : 70 ( 22/ 31) :  6 ( 10/144) : 82 (130/157) :
v3.12..v3.13 : 33 ( 54/160) : 69 (174/252) : 62 ( 15/ 24) :  0 (  0/ 66) : 83 (104/125) :
v3.13..v3.14 : 41 ( 71/173) : 70 (181/258) : 66 ( 16/ 24) :  6 (  4/ 64) : 81 (140/171) :
v3.14..v3.15 : 47 ( 91/191) : 71 (209/294) : 78 ( 55/ 70) :  8 (  5/ 61) : 91 (139/152) :
v3.15..v3.16 : 48 (103/212) : 64 (163/253) : 78 ( 36/ 46) : 13 ( 14/101) : 78 (107/137) :
v3.16..v3.17 : 30 ( 45/147) : 82 (246/299) : 72 ( 16/ 22) :  1 (  1/ 51) : 68 ( 30/ 44) :
v3.17..v3.18 : 53 ( 82/154) : 77 (221/286) : 73 ( 50/ 68) :  1 (  1/ 66) : 80 (120/149) :
v3.18..v3.19 : 45 ( 74/161) : 73 (267/363) : 96 ( 29/ 30) :  3 (  1/ 26) : 85 ( 70/ 82) :
v3.19..v4.1  : 50 (153/304) : 71 (513/716) : 82 ( 60/ 73) : 13 ( 16/118) : 80 (173/216) :
  v4.1..v4.2  : 56 ( 96/170) : 63 (475/752) : 84 ( 50/ 59) : 10 (  6/ 56) : 69 ( 83/119) :
  v4.2..v4.3  : 35 ( 67/187) : 75 (279/368) : 72 ( 21/ 29) :  6 (  3/ 48) : 63 ( 47/ 74) :
  v4.3..v4.4  : 34 ( 60/176) : 68 (231/336) : 76 ( 26/ 34) :  4 (  2/ 42) : 73 (102/138) :
  v4.4..v4.5  : 32 ( 72/220) : 57 (156/273) : 74 ( 29/ 39) : 25 ( 12/ 47) : 83 (106/127) :
  v4.5..v4.6  : 42 ( 84/199) : 65 (324/495) : 89 ( 42/ 47) :  4 (  3/ 68) : 69 ( 69/ 99) :
  v4.6..v4.7  : 41 ( 91/217) : 70 (229/327) : 81 ( 26/ 32) : 25 ( 13/ 52) : 63 (101/158) :
  v4.7..v4.8  : 39 ( 98/247) : 64 (272/425) : 66 ( 20/ 30) :  2 (  3/125) : 60 ( 68/112) :
  v4.8..v4.9  : 42 ( 63/150) : 58 (189/321) : 80 ( 34/ 42) : 13 ( 17/129) : 48 ( 31/ 64) :

xfs seems to be good. So there may be hints to improve the problem.


> Another problem, somehow related, is that there are areas which have
> evolved into a really bad shape because nobody has really payed
> attention to them from the architectural POV when they were merged. To
> name one the memory hotplug doesn't seem very healthy, full of kludges,
> random hacks and fixes for fixes working for a particualr usecase
> without any longterm vision. We have allowed to (ab)use concepts like
> ZONE_MOVABLE which are finding new users because that seems to be the
> simplest way forward. Now we are left with fixing the code which has
> some fundamental issues because it is used out there. Are we going to do
> anything about those? E.g. generate a list of them, discuss how to make
> that code healthy again and do not allow new features until we sort that
> out?
>

I've joined memory hotplug development since 2011. To make enhancement
of memory hotplug healthy, I'd like to join the discussion.

Thanks,
Yasuaki Ishimatsu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
