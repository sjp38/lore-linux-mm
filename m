Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 627BE6B0071
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 08:35:50 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so491826oag.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 05:35:49 -0700 (PDT)
Message-ID: <5087E09A.3080101@gmail.com>
Date: Wed, 24 Oct 2012 20:35:38 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: ksm questions
References: <5087CED1.2030307@gmail.com> <5087D50D.8000101@ravellosystems.com>
In-Reply-To: <5087D50D.8000101@ravellosystems.com>
Content-Type: multipart/alternative;
 boundary="------------040709060605010809040507"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Izik Eidus <izik.eidus@ravellosystems.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Petr Holasek <pholasek@redhat.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>

This is a multi-part message in MIME format.
--------------040709060605010809040507
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 10/24/2012 07:46 PM, Izik Eidus wrote:
> On 10/24/2012 01:19 PM, Ni zhan Chen wrote:
>> Hi all,
>>
>> I have some questions about ksm.
>>
>> 1) khugepaged default nice value is 19, but ksmd default nice value 
>> is 5, why this big different?
>> 2) why ksm doesn't support pagecache and tmpfs now? What's the 
>> bottleneck?
>> 3) ksm kernel doc said that "KSM only merges anonymous(private) 
>> pages, never pagecache(file) pages". But where judege it should be 
>> private?
>> 4) ksm kernel doc said that "To avoid the instability and the 
>> resulting false negatives to be permanent, KSM re-initializes the 
>> unstable tree root node to an empty tree, at every KSM pass." But I 
>> can't find where re-initializes the unstable tree, could you explain me?
>
>
> in scan_get_next_rmap_item(), if (slot == &ksm_mm_head) then we do 
> root_unstable_tree = RB_ROOT; this will result in root_unstable_tree 
> being empty.

Hi Izik,

Another four questions, thank for your patience and excellent codes. :-)

1) Why judge if(page->mapping != expected_mapping) in function 
get_ksm_page called twice? And it also call put_page(page) in the second 
time, when this put_page associated get_page(page) is called?
2)
in function scan_get_next_rmap_item,
if (PageAnon(*page)) ||
     page_trans_compound_anon(*page)) {
     flush_anon_page(vma, *page, ksm_scan.address);
     flush_dcache_page(*page);
     rmap_item = get_next_rmap_item(slot,
????????????????????
why call flush_dcache_page here? in kernel doc 
Documentation/cachetlb.txt, it said that "Any time the kernel writes to 
a page cache page, _OR_ the kernel is about to read from a page cache 
page and user space shared/writable mappings of this page potentially 
exist, this routine is called", it is used for flush page cache related 
cpu cache, but ksmd only scan anonymous page.
3) in function remove_rmap_item_from_tree, how to understand formula age 
= (unsigned char) (ksm_scan.seqr - rmap_item->address); why need aging?
4) in function page_volatile_show, how to understand ksm_pages_volatile 
= ksm_rmap_items - ksm_pages_shared - ksm_pages_sharing - 
ksm_pages_unshared; I mean that how this formula can figure out "how 
many pages changing too fast to be placed in a tree"?

Regards,
Chen

>
>>
>> Thanks in advance. :-)
>>
>> Regards,
>> Chen
>>
>
>


--------------040709060605010809040507
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <div class="moz-cite-prefix">On 10/24/2012 07:46 PM, Izik Eidus
      wrote:<br>
    </div>
    <blockquote cite="mid:5087D50D.8000101@ravellosystems.com"
      type="cite">On 10/24/2012 01:19 PM, Ni zhan Chen wrote:
      <br>
      <blockquote type="cite">Hi all,
        <br>
        <br>
        I have some questions about ksm.
        <br>
        <br>
        1) khugepaged default nice value is 19, but ksmd default nice
        value is 5, why this big different?
        <br>
        2) why ksm doesn't support pagecache and tmpfs now? What's the
        bottleneck?
        <br>
        3) ksm kernel doc said that "KSM only merges anonymous(private)
        pages, never pagecache(file) pages". But where judege it should
        be private?
        <br>
        4) ksm kernel doc said that "To avoid the instability and the
        resulting false negatives to be permanent, KSM re-initializes
        the unstable tree root node to an empty tree, at every KSM
        pass." But I can't find where re-initializes the unstable tree,
        could you explain me?
        <br>
      </blockquote>
      <br>
      <br>
      in scan_get_next_rmap_item(), if (slot == &amp;ksm_mm_head) then
      we do root_unstable_tree = RB_ROOT; this will result in
      root_unstable_tree being empty.
      <br>
    </blockquote>
    <br>
    Hi Izik,<br>
    <br>
    Another four questions, thank for your patience and excellent codes.
    :-)<br>
    <br>
    1) Why judge if(page-&gt;mapping != expected_mapping) in function
    get_ksm_page called twice? And it also call put_page(page) in the
    second time, when this put_page associated get_page(page) is called?<br>
    2)<br>
    in function scan_get_next_rmap_item&#65292;<br>
    if (PageAnon(*page)) ||<br>
    &nbsp;&nbsp;&nbsp; page_trans_compound_anon(*page)) {<br>
    &nbsp;&nbsp;&nbsp; flush_anon_page(vma, *page, ksm_scan.address);<br>
    &nbsp;&nbsp;&nbsp; flush_dcache_page(*page);<br>
    &nbsp;&nbsp;&nbsp; rmap_item = get_next_rmap_item(slot,<br>
    &#12290;&#12290;&#12290;&#12290;&#12290;&#12290;&#12290;&#12290;&#12290;&#12290;&#12290;&#12290;&#12290;&#12290;&#12290;&#12290;&#12290;&#12290;&#12290;&#12290;<br>
    why call flush_dcache_page here? in kernel doc
    Documentation/cachetlb.txt, it said that "Any time the kernel writes
    to a page cache page, _OR_ the kernel is about to read from a page
    cache page and user space shared/writable mappings of this page
    potentially exist, this routine is called", it is used for flush
    page cache related cpu cache, but ksmd only scan anonymous page.<br>
    3) in function remove_rmap_item_from_tree, how to understand formula
    age = (unsigned char) (ksm_scan.seqr - rmap_item-&gt;address); why
    need aging?<br>
    4) in function page_volatile_show, how to understand
    ksm_pages_volatile = ksm_rmap_items - ksm_pages_shared -
    ksm_pages_sharing - ksm_pages_unshared; I mean that how this formula
    can figure out "how many pages changing too fast to be placed in a
    tree"?<br>
    <br>
    <meta http-equiv="content-type" content="text/html;
      charset=ISO-8859-1">
    <span style="color: rgb(34, 34, 34); font-family: arial, sans-serif;
      font-size: 14px; font-style: normal; font-variant: normal;
      font-weight: normal; letter-spacing: normal; line-height: normal;
      orphans: 2; text-align: -webkit-auto; text-indent: 0px;
      text-transform: none; white-space: normal; widows: 2;
      word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,
      255); display: inline !important; float: none; "></span>Regards,<br>
    Chen<br>
    <br>
    <blockquote cite="mid:5087D50D.8000101@ravellosystems.com"
      type="cite">
      <br>
      <blockquote type="cite">
        <br>
        Thanks in advance. :-)
        <br>
        <br>
        Regards,
        <br>
        Chen
        <br>
        <br>
      </blockquote>
      <br>
      <br>
    </blockquote>
    <br>
  </body>
</html>

--------------040709060605010809040507--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
