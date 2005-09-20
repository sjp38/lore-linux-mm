Message-ID: <432F7DD5.6050204@ccoss.com.cn>
Date: Tue, 20 Sep 2005 11:11:17 +0800
From: liyu <liyu@ccoss.com.cn>
MIME-Version: 1.0
Subject: [Question] How to understand Clock-Pro algorithm?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi, every in LKML/linux-mm:

    I have been read CLOCK-Pro paper since last week, and am going to 
write one python demo.

    After just read , I think I can understand it, however once I begin 
implement it, I
found there are many point that not clear.
   
    First, two important parameters Mc, Mh,

    In that paper, it assume total memory size is M. (in number of page)
   
    There is a formula:
      
       M = Mc+Mh.
      
        Mc, number of cold pages in memory,
        Mh, number of hot pages in memory.
   
    So, in clock list, we can keep track 2M page metadatas at most, we 
may include M
non-resident pages.
      
    In '4.3 operationes on searching vicim pages' , the authors said

    "we keep track of the number of non-resident cold pages, Once the number
exceeds m the memory size in number of pages. we terminted the test 
period of
the cold page pointed to by HAND-test."

    My question is out:As this paper words, the number of cold page is 
total of resident cold pages
and non-resident pages. It's the seem number of non-resident cold pages 
can not beyond M at all!
   
    I also have more questions on CLOCK-Pro. but this question is most 
doublt for me.

    Any clear word is welcome. thank in advanced.

    I suppose experience is more important than theory in 
page-replacement field, is it right?



liyu

   



   
   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
